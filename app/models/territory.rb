# == Schema Information
#
# Table name: territories
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE), not null
#  alpha2_code :string           not null
#  name        :string           not null
#  phone_code  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Territory < ApplicationRecord
  ## Associations
  has_one_attached :flag

  ## Validations
  validates :name, presence: true, uniqueness: true
  validates :phone_code, presence: true, format: { with: User::ONLY_NUMBERS_REGEX },
                         length: { minimum: 1, maximum: 3 }
  validates :alpha2_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) },
                          presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  ## Methods and helpers
  def flag_url
    return nil unless flag.attached?

    Rails.application.routes.url_helpers.url_for(flag)
  end
end
