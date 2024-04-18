module Users
  class AccountDeletionJob < ApplicationJob
    queue_as :default

    def perform(user)
      Users::AccountDeletion.call(user)
    end
  end
end
