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
require 'rails_helper'

RSpec.describe AppVersion, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
