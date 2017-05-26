class DeviseMailer < Devise::Mailer
  helper :application
  include AbstractController::Callbacks
  include Devise::Controllers::UrlHelpers
  include AdminNotifiable

  default template_path: 'devise/mailer'

  after_action :copy_email_to_alt

  def confirmation_instructions(record, token, opts={})
    @provider = Provider.last
    super
  end

  def reset_password_instructions(record, token, opt={})
    @token = record.reset_password_token
    devise_mail(record, :reset_password_instructions)
  end

  private

  def copy_email_to_alt
    provider = Provider.last
    DublicationMailer.notify(response_body, message.from.first, provider.alt_email, message.subject).deliver_now if provider.try(:alt_email?)
  end
end