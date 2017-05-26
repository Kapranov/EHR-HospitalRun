class PatientAppointmentsController < BasePatientController
  before_action :check_role

  def new
    @providers = Provider.all.map{ |provider| ["#{provider.title} #{provider.last_name} #{provider.first_name}", provider.id] }
  end

  def create
    patient_appointment = PatientAppointment.create(patients_appointment_params)
    if patient_appointment.persisted?
      flash[:notice] = creation_notification(patient_appointment)
    else
      flash[:error] = patient_appointment.errors.full_messages.to_sentence
    end
    redirect_to patients_path
  end

  private

  def patients_appointment_params
    params.require(:patient_appointment).permit(
      :provider_id,
      :patient_id,
      :date,
      :location,
      :appointment_type,
      :note,
      :phone,
      :phone_code,
      :phone_tel,
      :email
    )
  end

  def check_role
    authorize Patient, :patient?
  end
end
