module AccountDeletionFollowUps
  class TrackerHelper
    def initialize(user, note)
      @user = user
      @note = note
      @account_deletion_follow_up = @user&.account_deletion_follow_up
    end

    def self.call(...)
      new(...).call
    end

    def call
      return unless @user && @account_deletion_follow_up

      update_notes
    end

    private

    def update_notes
      return if @account_deletion_follow_up.notes&.include?(@note)

      notes = if @account_deletion_follow_up.notes.blank?
                @note
              else
                "#{@account_deletion_follow_up.notes}\n#{@note}"
              end
      @account_deletion_follow_up.update!(notes: notes)
    end
  end
end
