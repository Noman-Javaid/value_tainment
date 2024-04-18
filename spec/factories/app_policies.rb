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
FactoryBot.define do
  factory :app_policy do
    title { "MyString" }
    description { "MyString" }
    status { "MyString" }
    fexpert { false }
    individual { false }
    global { false }
    has_changed { false }
    version { "MyString" }
  end
end
