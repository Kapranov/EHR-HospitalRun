class DublicationMailer < ActionMailer::Base
  def notify(body, from, to, subject)
    @body = body
    mail(from: from, to: to, subject: subject)
  end
end