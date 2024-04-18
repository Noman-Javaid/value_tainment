# == Schema Information
#
# Table name: transfers
#
#  id                         :bigint           not null, primary key
#  amount                     :integer
#  balance_transaction_id_ext :string
#  destination_account_id_ext :string
#  destination_payment_id_ext :string
#  reversed                   :boolean
#  transfer_id_ext            :string
#  transfer_metadata          :jsonb            not null
#  transferable_type          :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  transferable_id            :uuid             not null
#
FactoryBot.define do
  factory :transfer do
    transferable { create(:expert_call) }
    transfer_id_ext { "tr_1LpyY6A3xt8sfcfkdc3eMXFE" }
    amount { 5_000 }
    destination_account_id_ext { "acct_1L06fcAcEzQh1MY0" }
    balance_transaction_id_ext { "txn_1JUhvwA3xt8sfcfk1vnVsI01" }
    destination_payment_id_ext { "py_1LpyY6AcEzQh1MY0K1zjAIzB" }
    reversed { false }
    transfer_metadata { "{}" }

    trait :with_metadata do
      transfer_metadata do
        {
          id: 'tr_1LpyY6A3xt8sfcfkdc3eMXFE',
          object: 'transfer',
          amount: 4000,
          amount_reversed: 0,
          balance_transaction: 'txn_1JUhvwA3xt8sfcfk1vnVsI01',
          created: 1665079918,
          currency: 'usd',
          description: nil,
          destination: 'acct_1L06fcAcEzQh1MY0',
          destination_payment: 'py_1LpyY6AcEzQh1MY0K1zjAIzB',
          livemode: false,
          metadata: {},
          reversals: {
            object: 'list',
            data: [],
            has_more: false,
            url: '/v1/transfers/tr_1LpyY6A3xt8sfcfkdc3eMXFE/reversals'
          },
          reversed: false,
          source_transaction: nil,
          source_type: 'card',
          transfer_group: nil
        }
      end
    end
  end
end
