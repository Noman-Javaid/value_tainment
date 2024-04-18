module Users
  class DeleteAccountsJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      users_to_delete = User.pending_for_deletion
      users_to_delete.each do |user|
        Users::AccountDeletionJob.perform_later(user)
      end
    end
  end
end
