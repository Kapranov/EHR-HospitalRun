module User::Trialable
  delegate :trial_active?, :trial_period, to: :provider, allow_nil: true

  def trial?
    role == :Provider ? provider.try(:trial?) : false
  end
end