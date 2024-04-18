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
require 'rails_helper'

RSpec.describe ContactFormSubmission, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
