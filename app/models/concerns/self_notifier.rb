class SelfNotifier

  class << self

    def simple_notify(user, action)
      notify(user, "Your account was #{action}")
    end

    private

    def notify(user, message)
      SelfNotifierMailer.notify(user, message).deliver_now
    end
  end
end