class SelfNotifierMailer < ApplicationMailer
  def notify(user, body)
    @body = body
    mail(to: user.email, subject: 'EHR notification')
  end
end