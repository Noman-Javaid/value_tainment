module Interactions
  class DeletionHelper
    VALID_STATUS_TO_NOTIFY = %w[pending draft_answered requires_confirmation requires_reschedule_confirmation scheduled].freeze
    VALID_STATUS_TO_DELETE = %w[expired failed declined incompleted] + VALID_STATUS_TO_NOTIFY

    # TODO- Update account deletion flow, refund (with payment_status=succeded) instead of deletion
    def initialize(interactions, as_individual)
      @interactions = interactions
      @as_individual = as_individual
    end

    def self.call(...)
      new(...).call
    end

    def call
      return unless @interactions&.any?

      @interactions.each do |interaction|
        interaction.destroy! if valid_to_delete?(interaction)
        Interactions::DeletionEventNotificationSender.call(interaction, @as_individual) if valid_to_notify?(interaction)
      rescue StandardError => e
        follow_up_tracker(interaction, e.message)
        Honeybadger.notify(e)
        next
      end
    end

    private

    def valid_to_notify?(interaction)
      return VALID_STATUS_TO_NOTIFY.include? interaction.status if interaction.instance_of?(QuickQuestion)

      VALID_STATUS_TO_NOTIFY.include? interaction.call_status
    end

    def valid_to_delete?(interaction)
      return VALID_STATUS_TO_DELETE.include? interaction.status if interaction.instance_of?(QuickQuestion)

      VALID_STATUS_TO_DELETE.include? interaction.call_status
    end

    def follow_up_tracker(interaction, error_message)
      note = "**In class #{self.class} with #{interaction.class} id: #{interaction.id} "\
             "as individual? -> #{@as_individual}, Error: #{error_message}"
      user = @as_individual ? interaction.individual.user : interaction.expert.user
      AccountDeletionFollowUps::TrackerHelper.call(user, note)
    end
  end
end
