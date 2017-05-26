module AdminNotifiable
  def self.included(base)
    base.class_eval do
      after_action :copy_email_to_admin
    end
  end

  private

  def copy_email_to_admin
    AdminNotifierMailer.notify(response_body).deliver_now
  end
end