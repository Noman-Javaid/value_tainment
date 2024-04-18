# frozen_string_literal: true

# == Schema Information
#
# Table name: transactions
#
#  id                    :bigint           not null, primary key
#  amount                :integer          not null
#  charge_type           :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  expert_id             :uuid             not null
#  expert_interaction_id :bigint
#  individual_id         :uuid             not null
#  payment_id            :uuid
#  stripe_transaction_id :string           not null
#  time_addition_id      :uuid
#
# Indexes
#
#  index_transactions_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (expert_interaction_id => expert_interactions.id)
#  fk_rails_...  (individual_id => individuals.id)
#  fk_rails_...  (payment_id => payments.id)
#
class Transaction < ApplicationRecord
  ## Constants
  CHARGE_TYPE_CONFIRMATION = 'payment_intent_confirmation'
  CHARGE_TYPE_CANCELATION = 'payment_intent_cancelation'
  CHARGE_TYPE_ON_INTENT_CREATED = 'payment_on_hold_intent_created'

  ## Associations
  belongs_to :expert
  belongs_to :individual
  belongs_to :expert_interaction
  belongs_to :time_addition, optional: true
  belongs_to :payment, optional: true

  ## Scopes
  scope :most_recent, -> { order(created_at: :desc) }
end
