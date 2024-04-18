module Stripes
  module Refunds
    class RefundExpertCallHandler
      def initialize(interaction, amount = nil)
        @interaction = interaction
        @amount = amount
      end

      def self.call(...)
        new(...).call
      end

      def call
        return unless @interaction

        expert_call_refund = Stripes::Refunds::RefundInteractionHandler.call(@interaction, @amount)
        time_additions_refunds = []
        @interaction.time_additions.confirmed.each do |time_addition|
          time_addition_refund = Stripes::Refunds::RefundInteractionHandler.call(time_addition, @amount)
          time_additions_refunds << time_addition_refund
        end
        expert_call_refund.to_h.merge!(
          { time_additions_refunds: time_additions_refunds }
        ).with_indifferent_access
      end
    end
  end
end
