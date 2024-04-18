# frozen_string_literal: true

# == Schema Information
#
# Table name: participant_events
#
#  id             :bigint           not null, primary key
#  duration       :integer
#  event_datetime :datetime         not null
#  event_name     :string           not null
#  expert         :boolean          default(FALSE), not null
#  initial        :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  participant_id :string           not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#
class ParticipantEvent < ApplicationRecord
  ## Constants
  PARTICIPANT_CONNECTED = 'participant-connected'
  PARTICIPANT_DISCONNECTED = 'participant-disconnected'

  ## Associations
  belongs_to :expert_call

  ## Validations
  validates :participant_id, presence: true
  validates :event_name, presence: true
  validates :event_datetime, presence: true

  ## Scopes
  scope :disconnected, -> { where(event_name: PARTICIPANT_DISCONNECTED) }
  scope :connected, -> { where(event_name: PARTICIPANT_CONNECTED) }
  scope :experts, -> { where(expert: true) }

  def participant
    return Expert.find_by(id: participant_id) if expert

    Individual.find_by(id: participant_id)
  end
end
