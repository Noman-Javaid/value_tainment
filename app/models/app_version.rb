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
class AppVersion < ApplicationRecord
  attribute :supported, :boolean, default: true

  enum platform: { android: 'Android', ios: 'iOS' }
end
