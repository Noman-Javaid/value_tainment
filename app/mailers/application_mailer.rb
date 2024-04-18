class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEFAULT_EMAIL_ADDRESS'] # rubocop:todo Rails/EnvironmentVariableAccess
  layout 'mailer'
end
