# == Schema Information
#
# Table name: account_deletion_follow_ups
#
#  id                      :bigint           not null, primary key
#  notes                   :text
#  required_for_expert     :boolean          default(FALSE)
#  required_for_individual :boolean          default(FALSE)
#  status                  :integer          default("created")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  stripe_account_id       :string
#  stripe_customer_id      :string
#  user_id                 :bigint
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AccountDeletionFollowUp < ApplicationRecord
  RESOLVED_NOTE = 'Resolved by service.'.freeze

  ## Associations
  belongs_to :user

  ## Enums
  enum status: { created: 0, requires_revision: 1, in_revision: 2, resolved: 3 }

  ## Validations
  validates :user, presence: true, on: :create
end
