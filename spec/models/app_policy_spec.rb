# == Schema Information
#
# Table name: app_policies
#
#  id          :bigint           not null, primary key
#  description :string           default([]), is an Array
#  expert      :boolean
#  global      :boolean          default(FALSE)
#  has_changed :boolean          default(TRUE)
#  individual  :boolean
#  status      :string           default("active")
#  title       :string           not null
#  version     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe AppPolicy, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
