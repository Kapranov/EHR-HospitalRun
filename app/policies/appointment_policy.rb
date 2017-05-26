class AppointmentPolicy < BasePolicy
  policies :create?, :update?, :reschedule?

  def show?
    if current_user.patient?
      current_user.patient.id == @record.patient_id
    else
      available?(__method__)
    end
  end
end
