namespace :users do
  desc 'delete pending user accounts'
  task account_deletion: :environment do
    Users::DeleteAccountsJob.perform_now
  end
end
