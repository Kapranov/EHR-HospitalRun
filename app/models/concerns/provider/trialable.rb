module Provider::Trialable
  def trial?
    trial.present?
  end

  def trial_5?
    trial? && (0..5).to_a.include?(trial_period)
  end

  def trial_20?
    trial? && (6..20).to_a.include?(trial_period)
  end

  def trial_active?
    trial? && created_at + trial.days > DateTime.now
  end

  def trial_period
    trial_active? ? ((created_at + trial.days - Time.now) / 3600 / 24).round : 0
  end

  def to_paid
    DoubleNotifier.notify(user, notify_message) if update(trial: nil)
  end

  def to_trial
    DoubleNotifier.notify(user, notify_message) if update(trial: 30)
  end

  private

  def notify_message
    "set as #{trial? ? 'trial' : 'paid'}"
  end
end