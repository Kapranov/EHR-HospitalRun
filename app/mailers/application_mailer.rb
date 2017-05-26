class ApplicationMailer < ActionMailer::Base
  include AbstractController::Callbacks
  include AdminNotifiable
  include Dublicatable

  default from: Rails.application.secrets.default_email_reply
  layout 'mailer'
end
