class Experts::DeattachAssociationsHelper
  # This service replace the expert user with the default anonymous expert
  def initialize(expert, association_type)
    @expert = expert
    @association_type = association_type
  end

  def self.call(...)
    new(...).call
  end

  def call
    return true unless @expert
    return false unless default_expert

    deattachment_completed = true
    @expert.send(@association_type).each do |association|
      association.update!(expert: default_expert)
    rescue StandardError => e
      deattachment_completed = false
      follow_up_tracker(association, e.message)
      next
    end
    deattachment_completed
  end

  private

  def default_expert
    @default_expert ||= User.where(is_default: true).first&.expert
  end

  def follow_up_tracker(association, error_message)
    note = "**In class #{self.class} with #{association.class} id: #{association.id} as "\
           "individual? -> false, Error: #{error_message}"
    AccountDeletionFollowUps::TrackerHelper.call(@expert.user, note)
  end
end
