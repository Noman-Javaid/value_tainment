namespace :individual_profile_mail_notification do
  desc 'Send notification by email to expert users that do not have an individual profile yet'
  task send_email: :environment do
    users = User.joins(:expert).where.missing(:individual)
    puts "Sending email to #{users.count} users"
    users.each do |user|
      puts "Senging email to #{user.email}"
      IndividualProfileCreationMailer.send_to(user).deliver_now
      puts 'Email sent'
    end
    puts 'Done'
  end
end
