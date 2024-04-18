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
class ContactFormSubmission < ApplicationRecord
  # Validation rules
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 500 }
end
