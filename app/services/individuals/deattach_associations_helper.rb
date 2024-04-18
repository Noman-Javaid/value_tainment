class Individuals::DeattachAssociationsHelper
  # This service replace the individiual user with the default anonymous individiual
  def initialize(individual, association_type)
    @individual = individual
    @association_type = association_type
  end

  def self.call(...)
    new(...).call
  end

  def call
    return true unless @individual
    return false unless default_individual

    deattachment_completed = true
    @individual.send(@association_type).each do |association|
      association.update!(individual: default_individual)
    rescue StandardError => e
      deattachment_completed = false
      follow_up_tracker(association, e.message)
      next
    end
    deattachment_completed
  end

  private

  def default_individual
    @default_individual ||= User.where(is_default: true).first&.individual
  end

  def follow_up_tracker(association, error_message)
    note = "**In class #{self.class} with #{association.class} id: #{association.id} as "\
           "individual? -> true, Error: #{error_message}"
    AccountDeletionFollowUps::TrackerHelper.call(@individual.user, note)
  end
end
