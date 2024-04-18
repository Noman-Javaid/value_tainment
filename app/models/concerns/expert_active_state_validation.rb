module ExpertActiveStateValidation
  extend ActiveSupport::Concern

  included do
    before_validation :expert_active_state, on: :create, if: :expert
  end

  private

  def expert_active_state
    return if expert.active

    errors.add :base, 'The Expert User is inactive at the moment'
  end
end
