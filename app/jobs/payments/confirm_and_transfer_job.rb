module Payments
  class ConfirmAndTransferJob < ApplicationJob
    queue_as :transfer_payments

    def perform(*_args)
      questions = QuickQuestion.where(
        status: %w[answered denied_complaint],
        answer_date: ..SettingVariable::GRACE_PERIOD_IN_MINUTES.ago
      )

      expert_calls = ExpertCall.where(
        call_status: %w[finished denied_complaint],
        scheduled_time_start: ..SettingVariable::GRACE_PERIOD_IN_MINUTES.ago
      )

      interactions = questions + expert_calls
      process_payments(interactions)
    rescue StandardError => e
      logger.error("Errors Processing transfers #{e}")
      e.backtrace.each { |line| logger.error line }
      Honeybadger.notify(e)
    end

    # confirm payment intent to complete transfer to connected account
    def process_payments(interactions)
      interactions.each do |interaction|
        # previous flow
        if interaction.instance_of?(ExpertCall) && interaction.payment_id.blank?
          interaction.update!(call_status: 'incompleted')
          next
        end
        next if interaction.payment_status != 'succeeded'

        begin
          # payment upfront flow
          interaction.transfer
          interaction.save!
        rescue
          interaction.untransfer!
          next
        end
      end
    end
  end
end
