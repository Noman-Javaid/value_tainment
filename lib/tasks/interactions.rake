namespace :interactions do
  desc 'expire interactions when time is over'
  task expire: :environment do
    Interactions::CheckInteractionsToExpireJob.perform_now
  end
end
