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
require 'rails_helper'

RSpec.describe AccountDeletionFollowUp, type: :model do
  subject(:account_deletion_follow_up) { create(:account_deletion_follow_up) }

  context 'with valid factory' do
    it { expect(subject).to be_valid } # rubocop:todo RSpec/NamedSubject
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
