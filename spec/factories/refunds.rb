# == Schema Information
#
# Table name: refunds
#
#  id                    :bigint           not null, primary key
#  amount                :integer
#  payment_intent_id_ext :string
#  refund_id_ext         :string
#  refund_metadata       :jsonb            not null
#  refundable_type       :string           not null
#  status                :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  refundable_id         :uuid             not null
#
FactoryBot.define do
  factory :refund do
    refundable { create(:expert_call) }
    payment_intent_id_ext { "pi_3KXBl7A3xt8sfcfk0Qy89Rip" }
    refund_id_ext { "re_3KXBl7A3xt8sfcfk0TdGUXXH" }
    status { "succeeded" }
    amount { 5_000 }
    refund_metadata { "{}" }
  end

  trait :with_metadata do
    refund_metadata do
      {
        id: 're_3KXBl7A3xt8sfcfk0TdGUXXH',
        object: 'refund',
        amount: 5000,
        balance_transaction: nil,
        charge: 'ch_3KXBl7A3xt8sfcfk0o8gV1LY',
        created: 1646431197,
        currency: 'usd',
        metadata: {},
        payment_intent: 'pi_3KXBl7A3xt8sfcfk0Qy89Rip',
        reason: 'expired_uncaptured_charge',
        receipt_number: nil,
        source_transfer_reversal: nil,
        status: 'succeeded',
        transfer_reversal: nil
      }
    end
  end
end
