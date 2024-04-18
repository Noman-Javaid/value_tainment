RSpec.shared_context 'expert_call_user_for_notifications' do # rubocop:todo RSpec/ContextWording
  let(:category) { create(:category) }
  let(:individual_user) { create(:user, :individual, :with_profile) }
  let(:expert_user) { create(:user, :expert, :with_profile) }
  let(:individual) { individual_user.individual }
  let(:individual_device) { create(:device, user: individual_user) }
  let(:expert_device) { create(:device, user: expert_user) }
  let(:expert_user_update_params) do
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
  let(:expert) do
    expert_user.expert.update!(expert_user_update_params)
    expert_user.expert
  end
end
