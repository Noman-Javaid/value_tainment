namespace :users do
  desc 'fetch each expert, sets its user in profile_edit status and check if is valid'\
       'to set it as profile_set'
  task mark_as_profile_set: :environment do
    Expert.find_each do |expert|
      expert.user.start_setting_profile
      next unless expert.valid? && expert.user.valid?

      expert.user.mark_as_profile_set!
    end
  end
end
