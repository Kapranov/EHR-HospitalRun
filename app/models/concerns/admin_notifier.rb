class AdminNotifier
  class << self
    def notify_admin_with(user, action)
      notify_admin("#{user.role} #{user.person.try(:full_name)} #{user.email} was #{action} at #{Time.now.strftime(Date::DATE_FORMATS[:exact_time])}")
    end

    def notify_admin(message)
      TextMessage.create(to: full_phone_number, body: message)
      AdminNotifierMailer.notify(message).deliver_now
    end

    private

    def full_phone_number
      Rails.application.secrets.admin_country_code + Rails.application.secrets.admin_phone_number
    end
  end
end