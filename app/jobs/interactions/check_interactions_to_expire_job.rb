module Interactions
  class CheckInteractionsToExpireJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      questions = QuickQuestion.where(
        status: %w[pending draft_answered],
        created_at: ..7.days.ago
      )
      # Update/fix/check when adding extra time to call is implemented
      expert_calls = ExpertCall.where(
        call_status: %w[requires_confirmation requires_reschedule_confirmation requires_time_change_confirmation],
        scheduled_time_end: ..Time.current
      )

      # private_chats
      private_chats = PrivateChat.pending.where(created_at: ..7.days.ago)
      interactions = questions + expert_calls + private_chats
      expire_interactions(interactions)
    rescue StandardError => e
      Rails.logger.info("Errors Processing Interactions To Expire -> #{e}")
      Honeybadger.notify(e)
    end

    def expire_interactions(interactions)
      interactions.each do |interaction|
        interaction.expire!
        Notifications::Individuals::QuickQuestionNotifier.new(interaction).conversation_expired if interaction.is_a?(PrivateChat)
        Notifications::Individuals::QuickQuestionNotifier.new(interaction).expired_question if interaction.is_a?(QuickQuestion)
      end
    end
  end
end
