# == Schema Information
#
# Table name: experts
#
#  id                           :uuid             not null, primary key
#  bank_account_last4           :string
#  biography                    :text
#  can_receive_stripe_transfers :boolean          default(FALSE)
#  extra_user_rate              :integer
#  featured                     :boolean          default(FALSE)
#  instagram_url                :string
#  interactions_count           :integer          default(0), not null
#  linkedin_url                 :string
#  one_to_five_video_call_rate  :integer
#  one_to_one_video_call_rate   :integer
#  payout_percentage            :integer          default(80)
#  pending_events               :integer          default(0), not null
#  quick_question_rate          :integer
#  quick_question_text_rate     :integer          default(50)
#  quick_question_video_rate    :integer          default(70)
#  rating                       :float            default(0.0)
#  ready_for_deletion           :boolean          default(FALSE)
#  reviews_count                :integer
#  slug                         :string
#  status                       :integer          default("pending"), not null
#  stripe_account_set           :boolean          default(FALSE)
#  total_earnings               :integer          default(0), not null
#  twitter_url                  :string
#  video_call_rate              :integer          default(15)
#  website_url                  :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  stripe_account_id            :string
#  stripe_bank_account_id       :string
#  user_id                      :bigint           not null
#
# Indexes
#
#  index_experts_on_slug                                   (slug) UNIQUE
#  index_experts_on_user_id                                (user_id)
#  index_experts_stripe_account_id_and_set                 (stripe_account_id,stripe_account_set)
#  index_experts_stripe_account_set_and_can_get_transfers  (stripe_account_set,can_receive_stripe_transfers)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Expert, type: :model do
  subject(:expert) { user.expert }

  let(:user) { create(:user, role: 'expert') }
  let(:expert_user) { create(:expert) }
  let(:expert_user_with_profile) { create(:expert, :with_profile) }

  describe 'has valid factory' do
    context 'when expert user' do
      it { expect(expert_user).to be_valid }
    end

    context 'when expert user with profile' do
      it { expect(expert_user_with_profile).to be_valid }
    end
  end

  describe 'attributes' do
    it { is_expected.to define_enum_for(:status).with_values({ pending: 0, verified: 1, rejected: 2 }) }
  end

  describe 'ActiveModel validations' do
    it { is_expected.to validate_presence_of(:user) }
  end

  describe 'validations for an expert user with profile' do
    subject do
      expert = create(:expert)
      expert.user.start_setting_profile
      expert
    end

    context 'tests for presence' do # rubocop:todo RSpec/ContextWording
      it { is_expected.to validate_presence_of(:biography) }

      it { is_expected.to validate_presence_of(:quick_question_text_rate) }

      it { is_expected.to validate_presence_of(:quick_question_video_rate) }

      it { is_expected.to validate_presence_of(:video_call_rate) }

    end

    context 'tests for numericality validation' do # rubocop:todo RSpec/ContextWording
      it { is_expected.to validate_numericality_of(:quick_question_text_rate) }

      it { is_expected.to validate_numericality_of(:video_call_rate) }

      it { is_expected.to validate_numericality_of(:quick_question_video_rate) }

    end

    context 'tests for length in biography' do # rubocop:todo RSpec/ContextWording
      it { is_expected.to validate_length_of(:biography).is_at_most(1000) }
    end

    # rubocop:todo RSpec/ContextWording
    context 'tests for website_url, linkedin_url and social media urls invalid format' do
      # rubocop:enable RSpec/ContextWording
      it { is_expected.not_to allow_value('32dsafd').for(:website_url) }

      it { is_expected.not_to allow_value('www.----21').for(:linkedin_url) }

      it { is_expected.not_to allow_value('ww....').for(:twitter_url) }

      it { is_expected.not_to allow_value('test!!').for(:instagram_url) }
    end

    # rubocop:todo RSpec/ContextWording
    context 'tests for website_url, linkedin_url and social media urls valid format' do
      # rubocop:enable RSpec/ContextWording
      it { is_expected.to allow_value('wwww.minnect.com').for(:website_url) }

      it { is_expected.to allow_value('www.linkedin.com/company/koombea').for(:linkedin_url) }

      it { is_expected.to allow_value('www.twitter.com/koombea').for(:twitter_url) }

      it { is_expected.to allow_value('www.instagram.com/koombea').for(:instagram_url) }
    end
  end

  describe 'ActiveRecord associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:quick_questions).dependent(:destroy) }
    it { is_expected.to have_many(:expert_calls).dependent(:destroy) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
    it { is_expected.to have_many(:complaints).dependent(:destroy) }
  end

  describe 'scopes' do
    describe '.search_by_name' do
      let!(:user1) { create(:user, :expert, first_name: 'Expert 1', last_name: 'User') }
      let!(:user2) { create(:user, :expert, first_name: 'Expert 2', last_name: 'User') }
      let!(:another_user) { create(:user, :expert, first_name: 'Another', last_name: 'Expert') }
      let!(:expert1) { user1.expert }
      let!(:expert2) { user2.expert }
      let!(:another_expert) { another_user.expert }

      context 'when searched for "Expert"' do
        it 'returns all the experts' do
          expect(described_class.search_by_name('Expert')).to contain_exactly(expert1, expert2, another_expert)
        end
      end

      context 'when searched for "EXPERT"' do
        it 'returns all the experts' do
          expect(described_class.search_by_name('EXPERT')).to contain_exactly(expert1, expert2, another_expert)
        end
      end

      context 'when searched for "expert"' do
        it 'returns all the experts' do
          expect(described_class.search_by_name('expert')).to contain_exactly(expert1, expert2, another_expert)
        end
      end

      context 'when searched for "expert user"' do
        it 'returns only experts 1 and 2' do
          expect(described_class.search_by_name('expert user')).to contain_exactly(expert1, expert2)
        end
      end

      context 'when searched for "user expert"' do
        it 'returns only experts 1 and 2' do
          expect(described_class.search_by_name('user expert')).to contain_exactly(expert1, expert2)
        end
      end

      context 'when searched for "1"' do
        it 'returns only expert 1' do
          expect(described_class.search_by_name('1')).to contain_exactly(expert1)
        end
      end

      context 'when searched for ""' do
        it 'returns an empty list' do
          expect(described_class.search_by_name('')).to be_empty
        end
      end

      context 'when searched for "something that does not fit any user"' do
        it 'returns an empty list' do
          expect(described_class.search_by_name('something that does not fit any user')).to be_empty
        end
      end
    end
  end

  describe 'before_validation' do
    context 'without a previous status defined' do
      it 'defines the status as pending' do
        expert = build(:expert)
        expert.valid?
        expect(expert.pending?).to be(true)
      end
    end

    context 'with pending as the previous status' do
      it 'keeps pending as the status' do
        expert = build(:expert, status: :pending)
        expert.valid?
        expect(expert.pending?).to be(true)
      end
    end

    context 'with any valid previous status except pending' do
      it 'keeps the current status' do
        statuses = described_class.statuses.keys - ['pending']
        statuses.each do |status|
          expert = build(:expert, status: status)
          expert.valid?
          expect(expert.status).to eq(status)
        end
      end
    end
  end

  describe 'public instance methods' do
    describe 'responds to its methods' do
      it { is_expected.to respond_to(:verify!) }
      it { is_expected.to respond_to(:reject!) }
    end

    describe 'executes methods correctly' do
      describe '#verify!' do
        it 'sets the status to verified' do
          expert.verify!
          expect(expert).to be_verified
        end
      end

      describe '#reject!' do
        it 'sets the status to rejected' do
          expert.reject!
          expect(expert).to be_rejected
        end
      end

      describe '#age' do
        let(:date_of_birth) { nil }

        let(:expert) { build(:expert, user: nil) }
        let!(:user) do # rubocop:todo RSpec/LetSetup
          create(:user, role: 'expert', expert: expert, date_of_birth: date_of_birth)
        end

        let(:expected_age) { 0 }
        let(:described_method) { expert.age }

        context 'when the date_of_birth is set in the user' do
          let(:date_of_birth) { 3.years.ago }
          let(:expected_age) { 2 }

          before { Timecop.freeze(date_of_birth + expected_age.years + 1.day) }

          after { Timecop.return }

          it 'returns the calculated age' do
            expect(described_method).to eq(expected_age)
          end
        end

        # context satified by parent
        context 'when the date_of_birth is not set in the user' do
          it 'returns 0' do
            expect(described_method).to eq(expected_age)
          end
        end
      end

      describe '#pending_events_to_dollar' do
        it 'is a float' do
          expect(expert_user_with_profile.pending_events_to_dollar).to be_a_kind_of(Float)
        end
      end

      describe '#total_earnings_to_dollar' do
        it 'is a float' do
          expect(expert_user_with_profile.total_earnings_to_dollar).to be_a_kind_of(Float)
        end
      end

      describe '#add_to_total_earnings' do
        let(:amount) { 1000 }
        let!(:expected_pending_events) { expert_user_with_profile.pending_events - amount }
        let!(:expected_total_earnings) { expert_user_with_profile.total_earnings + amount }

        before { expert_user_with_profile.add_to_total_earnings(amount) }

        it 'substracts to pending_events' do
          expect(expert_user_with_profile.pending_events).to eq(expected_pending_events)
        end

        it 'adds to total_earnings' do
          expect(expert_user_with_profile.total_earnings).to eq(expected_total_earnings)
        end
      end
    end
  end
end
