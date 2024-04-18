RSpec.shared_context 'users_for_expert_endpoints' do # rubocop:todo RSpec/ContextWording
  let(:individual) { create(:individual, :with_profile) }
  let(:user) { create(:user, :expert, :with_profile) }
  let(:category) { create(:category) }
  let(:update_expert_user_params) do
    {
      biography: 'Business user with knowledge in Economics',
      website_url: 'www.user_web.com',
      linkedin_url: 'www.linkedin.com/user_profile',
      quick_question_rate: 50,
      one_to_one_video_call_rate: 50,
      one_to_five_video_call_rate: 50,
      extra_user_rate: 50,
      stripe_account_id: 'ac_3ijod2i3923jei2hio',
      stripe_account_set: true,
      can_receive_stripe_transfers: true,
      category_ids: [category.id],
      slug: 'slug'
    }
  end
  let!(:expert) do
    user.expert.update!(update_expert_user_params)
    user.expert
  end
  let(:individual_device) { create(:device, :with_ios, user: individual.user) }
  let(:expert_device) { create(:device, :with_ios, user: expert.user) }
end

RSpec.shared_context 'users_with_both_profiles' do # rubocop:todo RSpec/ContextWording
  include_context 'users_for_expert_endpoints'

  before { user.create_individual(username: 'with_both_profiles', stripe_customer_id: 'cu_123') }
end
