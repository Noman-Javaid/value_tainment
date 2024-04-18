module Interactions
  class DeletionEventNotificationSender
    def initialize(interaction, as_individual)
      @interaction = interaction
      @as_individual = as_individual
    end

    # TODO- Update account deletion flow, cancelation instead of deletion
    def self.call(...)
      new(...).call
    end

    def call
      return if @interaction.nil? || @interaction.persisted?

      users = users_to_send_notification
      Notifications::DeletedEventNotifier.new(notification_message, users).execute
    end

    private

    def notification_message
      klass_name = @interaction.class.to_s.underscore.titleize
      interaction_subject = truncate_event_subject
      user_role = @as_individual ? 'Individual' : 'Expert'
      "The pending #{klass_name} \"#{interaction_subject}\" has been deleted because the"\
      " #{user_role} User has deleted the account"
    end

    def users_to_send_notification
      users = @as_individual ? [@interaction.expert.user] : [@interaction.individual.user]
      @interaction.try(:guests)&.each do |guest|
        users.push(guest.user)
      end
      users
    end

    def truncate_event_subject
      return @interaction.question.truncate(100) if @interaction.respond_to?(:question)

      @interaction.title.truncate(100)
    end
  end
end
