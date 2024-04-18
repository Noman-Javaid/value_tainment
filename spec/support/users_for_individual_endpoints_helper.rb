RSpec.shared_context 'users_for_individual_endpoints' do # rubocop:todo RSpec/ContextWording
  let(:expert) { create(:expert, :with_profile, status: :verified) }
  let(:user) { create(:user, :with_profile) }
  let(:individual) { user.individual }
  let(:individual_device) { create(:device, :with_ios, user: individual.user) }
  let(:expert_device) { create(:device, :with_ios, user: expert.user) }
end
