# == Schema Information
#
# Table name: complaints
#
#  id                    :bigint           not null, primary key
#  content               :text
#  status                :string           default("requires_verification"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  expert_id             :uuid             not null
#  expert_interaction_id :bigint
#  individual_id         :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (expert_interaction_id => expert_interactions.id)
#  fk_rails_...  (individual_id => individuals.id)
#
require 'rails_helper'

RSpec.describe Complaint, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:expert) }
    it { is_expected.to belong_to(:individual) }
    it { is_expected.to belong_to(:expert_interaction).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(1000) }
  end

  describe 'factory object' do
    let(:complaint) { build(:complaint) }

    it 'has a valid factory' do
      expect(complaint).to be_valid
    end
  end

  describe 'callbacks' do
    describe '#mark_interaction_as_complained' do
      let(:expert) { create(:expert, :with_profile, status: :verified) }
      let(:user) { create(:user, :with_profile) }
      let(:individual) { user.individual }

      let(:quick_question) do
        create(:quick_question, :answered, individual: individual, expert: expert)
      end

      before do
        quick_question.update(answer: 'this is a test', answer_date: Time.current)
        create(:complaint, expert_interaction_id: quick_question.expert_interaction.id, content: 'this is a complaint')
      end

      it { expect(quick_question.reload).to be_filed_complaint }
    end

    describe '#resolve_interaction_complaint' do
      let(:expert) { create(:expert, :with_profile, status: :verified) }
      let(:user) { create(:user, :with_profile) }
      let(:individual) { user.individual }

      let(:quick_question) do
        create(:quick_question, :answered, individual: individual, expert: expert)
      end

      context 'when deny a complaint' do
        before do
          quick_question.update(answer: 'this is a test', answer_date: Time.current)
          complaint = create(:complaint, expert_interaction_id: quick_question.expert_interaction.id, content: 'this is a complaint')
          complaint.deny!
        end

        it { expect(quick_question.reload).to be_denied_complaint }
      end

      context 'when approve a complaint' do
        before do
          quick_question.update(answer: 'this is a test', answer_date: Time.current)
          complaint = create(:complaint, expert_interaction_id: quick_question.expert_interaction.id, content: 'this is a complaint')
          complaint.approve!
        end

        it { expect(quick_question.reload).to be_approved_complaint }
      end
    end
  end
end
