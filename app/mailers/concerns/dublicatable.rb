module Dublicatable
  def self.included(base)
    base.class_eval do
      after_action :copy_email_to_alt
    end
  end

  private

  def copy_email_to_alt
    email = message.to.first
    user = User.where(email: email).first
    DublicationMailer.notify(response_body, message.from.first, user.provider.alt_email, message.subject).deliver_now if user.present? && user.alt_email?
  end
end