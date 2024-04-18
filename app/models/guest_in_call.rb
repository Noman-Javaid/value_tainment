# == Schema Information
#
# Table name: guest_in_calls
#
#  id             :bigint           not null, primary key
#  confirmed      :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  individual_id  :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#  fk_rails_...  (individual_id => individuals.id)
#
class GuestInCall < ApplicationRecord
  ## Constants
  MAX_GUEST_COUNT = 58

  ## Associations
  belongs_to :expert_call, counter_cache: :guests_count
  belongs_to :individual, -> { active } # rubocop:todo Rails/InverseOf

  delegate :first_name, :last_name, :url_picture, to: :individual

  ## Validations
  validates :expert_call, presence: true
  validates :individual, presence: true
  validate :individual_be_active
  validate :limit_guest_count

  ## Methods and helpers
  private

  def individual_be_active
    errors.add(:individual, 'should be active') unless individual&.active
  end

  def limit_guest_count
    return unless expert_call

    errors.add(:individual, 'max limit guest count raised') if expert_call.guests_count + 1 > MAX_GUEST_COUNT
  end
end
