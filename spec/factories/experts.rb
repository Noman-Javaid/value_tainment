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
FactoryBot.define do
  factory :expert do
    association :user, factory: [:user, :expert]
    trait :with_profile do
      association :user, factory: [:user, :with_profile, :expert]
      biography { 'Business user with knowledge in Economics' }
      website_url { 'www.user_web.com' }
      linkedin_url { 'www.linkedin.com/user_profile' }
      instagram_url { 'www.instagram.com/user_profile' }
      twitter_url { 'www.twitter.com/user_profile' }
      quick_question_rate { 50 }
      one_to_one_video_call_rate { 5 }
      one_to_five_video_call_rate { 10 }
      extra_user_rate { 5 }
      stripe_account_id { 'ac_3ijod2i3923jei2hio' }
      stripe_account_set { true }
      can_receive_stripe_transfers { true }
      status { 1 }
      slug { 'slug'}
    end
    trait :with_categories do
      categories { |expert| [expert.association(:category)] }
    end
  end
end
