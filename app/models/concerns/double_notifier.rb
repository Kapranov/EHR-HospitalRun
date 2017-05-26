class DoubleNotifier
  class << self
    def notify(user, action)
      SelfNotifier.simple_notify(user, action)
      AdminNotifier.notify_admin_with(user, action)
    end
  end
end