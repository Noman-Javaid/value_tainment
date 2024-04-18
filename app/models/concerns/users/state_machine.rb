# frozen_string_literal: true

# related to Users
module Users
  # state machine for users
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm :status do
        state :registered, initial: true
        state :setting_profile, :profile_set

        event :start_setting_profile do
          transitions from: %i[registered profile_set], to: :setting_profile
        end

        event :mark_as_profile_set do
          transitions from: :setting_profile, to: :profile_set
        end
      end
    end
  end
end
