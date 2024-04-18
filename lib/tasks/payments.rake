namespace :payments do
  desc 'transfer payments to expert accounts'
  task transfer: :environment do
    Payments::ConfirmAndTransferJob.perform_now
  end

  desc 'refund payments to customer accounts'
  task refund: :environment do
    Payments::RefundsJob.perform_now
  end
end
