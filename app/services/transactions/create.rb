# frozen_string_literal: true

class Transactions::Create
  def initialize(interaction, transaction, is_refund)
    @time_addition = define_time_addition(interaction)
    @interaction = define_interaction(interaction)
    @transaction = transaction
    @charge_type = define_charge_type(is_refund)
    @payment = define_payment(transaction)
  end

  def self.call(...)
    new(...).call
  end

  def call
    Transaction.create(
      expert: @interaction.expert,
      individual: @interaction.individual,
      expert_interaction: @interaction.expert_interaction,
      charge_type: @charge_type,
      amount: @transaction.amount,
      stripe_transaction_id: @transaction.is_a?(Payment) ? @transaction.payment_id : @transaction.id,
      time_addition: @time_addition,
      payment: @payment
    )
  end

  private

  def define_interaction(interaction)
    time_addition?(interaction) ? interaction.expert_call : interaction
  end

  def define_charge_type(is_refund)
    is_refund ? Transaction::CHARGE_TYPE_CANCELATION : Transaction::CHARGE_TYPE_CONFIRMATION
  end

  def define_time_addition(interaction)
    time_addition?(interaction) ? interaction : nil
  end

  def define_payment(transaction)
    transaction.is_a?(Payment) ? transaction : nil
  end

  def time_addition?(interaction)
    interaction.instance_of?(TimeAddition)
  end
end
