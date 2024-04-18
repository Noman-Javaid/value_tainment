# == Schema Information
#
# Table name: app_versions
#
#  id              :bigint           not null, primary key
#  force_update    :boolean
#  is_latest       :boolean
#  platform        :string
#  release_date    :datetime
#  support_ends_on :datetime
#  supported       :boolean
#  version         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :app_version do
    platform { "MyString" }
    version { "MyString" }
    force_update { false }
    supported { false }
    is_latest { false }
    release_date { "2023-01-11 08:56:07" }
    support_ends_on { "2023-01-11 08:56:07" }
  end
end
