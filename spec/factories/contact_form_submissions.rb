# == Schema Information
#
# Table name: contact_form_submissions
#
#  id         :bigint           not null, primary key
#  email      :string
#  message    :text
#  name       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :contact_form_submission do
    name { "MyString" }
    email { "MyString" }
    title { "MyString" }
    message { "MyText" }
  end
end
