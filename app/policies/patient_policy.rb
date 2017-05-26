class PatientPolicy < BasePolicy
  policies :create?, :update?

  def patient?
    current_user.patient?
  end
end
