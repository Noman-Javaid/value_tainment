module Payments
  class RefundsJob < ApplicationJob
    queue_as :refunds

    def perform(*_args)
      questions = QuickQuestion.where(
        status: %w[expired], payment_status: 'succeeded'
      )

      expert_calls = ExpertCall.where(
        call_status: %w[declined failed incompleted expired], payment_status: 'succeeded'
      )

      interactions = questions + expert_calls
      refund_payments(interactions)
    rescue StandardError => e
      logger.error("Errors Processing refunds #{e}")
      e.backtrace.each { |line| logger.error line }
      Honeybadger.notify(e)
    end

    def refund_payments(interactions)
      interactions.each do |interaction|
        interaction.set_as_refunded
        interaction.save!
      rescue StandardError
        interaction.set_as_unrefunded!
        next
      end
    end
  end
end
