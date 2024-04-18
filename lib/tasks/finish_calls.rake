namespace :expert_calls do
  desc 'finish ongoing calls'
  task finish: :environment do
    ExpertCalls::RemoveOldCallsJob.perform_now
  end

  desc 'checks for ongoing calls with time left off'
  task check: :environment do
    ExpertCalls::UpdateCallToFinishJob.perform_now
  end
end
