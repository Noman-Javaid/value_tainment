RSpec.shared_examples_for 'correct structure response for expert profile' do
  it_behaves_like 'correct structure response for user'
  it { expect(json['data']['user']).to include('expert') }
  it { expect(json['data']['user']['expert']).to include('categories') }
  it { expect(json['data']['user']['expert']).to include('biography') }
  it { expect(json['data']['user']['expert']).to include('website_url') }
  it { expect(json['data']['user']['expert']).to include('linkedin_url') }
  it { expect(json['data']['user']['expert']).to include('quick_question_rate') }
  it { expect(json['data']['user']['expert']).to include('one_to_one_video_call_rate') }
  it { expect(json['data']['user']['expert']).to include('one_to_five_video_call_rate') }
  it { expect(json['data']['user']['expert']).to include('extra_user_rate') }
  it { expect(json['data']['user']['expert']).to include('status') }
  it { expect(json['data']['user']['expert']).to include('slug') }
end

RSpec.shared_examples_for 'correct structure response for individual profile' do
  it_behaves_like 'correct structure response for user'
  it { expect(json['data']['user']).to include('individual') }
  it { expect(json['data']['user']['individual']).to include('has_stripe_payment_method') }
  it { expect(json['data']['user']['individual']).to include('username') }
end

RSpec.shared_examples_for 'correct structure response for user' do
  it { expect(json['data']).to include('user') }
  it { expect(json['data']['user']).to include('email') }
  it { expect(json['data']['user']).to include('first_name') }
  it { expect(json['data']['user']).to include('last_name') }
  it { expect(json['data']['user']).to include('role') }
  it { expect(json['data']['user']).to include('active') }
  it { expect(json['data']['user']).to include('date_of_birth') }
  it { expect(json['data']['user']).to include('gender') }
  it { expect(json['data']['user']).to include('phone_number') }
  it { expect(json['data']['user']).to include('country') }
  it { expect(json['data']['user']).to include('city') }
  it { expect(json['data']['user']).to include('zip_code') }
end
