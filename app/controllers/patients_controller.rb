class PatientsController < BasePatientController
  layout 'patients'

  before_action :check_role_patient,  except: [:new, :create, :simple_create,
                                                     :update, :provider_full_info, :patients]
  before_action :check_role_provider, only:   [:new, :create, :simple_create, :patients]
  before_action :check_role,          only:   [:update, :provider_full_info]

  before_action :prepare_create_params, only: [:create, :simple_create]
  before_action :prepare_update_params, only: [:update]

  def index
    @message = current_user.inbox.order_by(:created_at).first
    @appointments = current_user.patient.appointments.where(:appointment_datetime.ge => Time.now.beginning_of_day)
                                                     .order_by(:appointment_datetime)
    @appointment = current_user.patient.appointments.order_by(:appointment_datetime).last
    @events_count = 1 + (@message.present? ? 1 : 0) + (@appointment.present? ? 1 : 0)
  end

  def new
    @user = User.new
  end

  def create
    user = User.create(user_params)
    if user.persisted?
      patient = Patient.create(patient_params.merge({created_by_id: current_user.provider.id, provider_id: current_user.main_provider.id, user_id: user.id, code: @code}))
      if patient.persisted?
        log 2, 0, patient.try(:id)
        redirect_to invite_to_portal_providers_path(patient_id: patient.id, from_patients_index: params[:from_patients_index], code: @code)
      else
        flash[:error] = patient.errors.full_messages.to_sentence
        redirect_to new_patient_path
      end
    else
      flash[:error] = user.errors.full_messages.to_sentence
      redirect_to new_patient_path
    end
  end

  def simple_create
    user = User.create(user_params)
    if user.persisted?
      patient = Patient.create(patient_params.merge({created_by_id: current_user.provider.id, provider_id: current_user.main_provider.id, user_id: user.id, code: @code}))
      if patient.persisted?
        log 2, 0, patient.try(:id)
        redirect_to new_appointment_path
      else
        flash[:error] = patient.errors.full_messages.to_sentence
        redirect_to add_patient_from_appointment_providers_path
      end
    else
      flash[:error] = user.errors.full_messages.to_sentence
      redirect_to add_patient_from_appointment_providers_path
    end
  end

  def update
    user = Patient.find(params[:id]).user
    if user.update(user_params)
      patient = user.patient
      emergency_contact = patient.emergency_contact
      next_kin = patient.next_kin if next_kin?
      if patient.update(patient_params) && emergency_contact.update(emergency_contact_params) && (!next_kin? || next_kin.update(next_kin_params))
        log 2, 1, patient.try(:id)
        flash[:notice] = updation_notification(patient)
      else
        flash[:error] = next_kin.errors.full_messages if next_kin?
        flash[:error] = (flash[:error] + patient.errors.full_messages + emergency_contact.errors.full_messages).to_sentence
      end
    else
      flash[:error] = user.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def appointments_show
    @appointments_upcoming = current_user.patient.appointments.where(:appointment_datetime.ge => Time.now).order_by(:appointment_datetime)
    @appointments_past = current_user.patient.appointments.where(:appointment_datetime.lt => Time.now).order_by(:appointment_datetime)
  end

  def appointments_status_actions
    if params[:status].present?
      status_id = params[:status].to_i
      Appointment.find(params[:id])
                 .update(status: status_id, appointment_status_id: status_id)     if params[:id].present?
      Appointment.where(:id.in => JSON.parse(params[:ids]))
                 .update_all(status: status_id, appointment_status_id: status_id) if params[:ids].present?
    end
    @appointments_upcoming = current_user.patient.appointments.where(:appointment_datetime.ge => Time.now).order_by(:appointment_datetime)
    render partial: 'patients/appointments_upcoming', locals: { appointments_upcoming: @appointments_upcoming }, layout: nil
  end

  def myhealth
    @medications = Medication.where(:id.in => current_user.patient.diagnoses.map(&:id))
  end

  def myprofile
    @secure_question = current_user.patient.secure_question
  end

  def provider_full_info
    render json: Provider.find(params[:provider_id]).main_provider.locations
  end

  def patients
    render json: if params[:part].present?
                  current_user.main_provider.find_patients_by(params[:part])
                else
                  current_user.provider.main_provider.patients_first(10)
                end.map{ |patient| { full_name: patient.full_name, id: patient.id } }
  end

  private

  def prepare_create_params
    @code = Activation.code
    params[:user].merge!({email: User.generate_default_email, no_email: true}) if params[:user][:email].blank?
    params[:user].merge!({password: @code,
                          password_confirmation: @code,
                          confirmed_at: Time.now,
                          role: :Patient})
  end

  def prepare_update_params
      params[:user][:patient][:birth] = params[:user][:patient][:birth].try(:to_time)
      params[:user][:no_email]        = params[:user][:no_email] == '1'
      params[:user][:email]           = User.generate_default_email if params[:user][:no_email]
    end

  def user_params
    params.require(:user).permit(
        :email,
        :no_email,
        :password,
        :password_confirmation,
        :confirmed_at,
        :role
    )
  end

  def patient_params
    params.require(:user).require(:patient).permit(
        :provider_id,
        :first_name,
        :last_name,
        :middle_name,
        :birth,
        :birth_date,
        :birth_time,
        :gender,
        :social_number,
        :patient_id,
        :active,
        :declined_portal_access,
        :preferred_language,
        :preferred_contact,
        :ethnicity,
        :american_race,
        :asian_race,
        :african_race,
        :hawaiian_race,
        :white_race,
        :undetermined_race,
        :email_reminder,
        :sms_reminder,
        :immunization_registry,
        :mobile_phone,
        :primary_phone,
        :work_phone,
        :primary_phone_code,
        :primary_phone_tel,
        :mobile_phone_code,
        :mobile_phone_tel,
        :work_phone_code,
        :work_phone_tel,
        :ext,
        :street_address,
        :city,
        :state,
        :zip,
        :profile_image
    )
  end

  def emergency_contact_params
    params.require(:user).require(:patient).require(:emergency_contact).permit(
        :first_name,
        :last_name,
        :middle_name,
        :relation,
        :mobile_phone,
        :mobile_phone_code,
        :mobile_phone_tel,
        :email,
        :street_address,
        :city,
        :state,
        :zip
    )
  end

  def next_kin_params
    params.require(:user).require(:patient).require(:next_kin).permit(
        :first_name,
        :last_name,
        :middle_name,
        :relation,
        :mobile_phone,
        :mobile_phone_code,
        :mobile_phone_tel,
        :email,
        :street_address,
        :city,
        :state,
        :zip
    )
  end

  def next_kin?
    params[:user][:patient][:next_kin].present?
  end

  def check_role_patient
    authorize Patient, :patient?
  end

  def check_role_provider
    authorize Patient, :create?
  end

  def check_role
    if current_user.role == :Provider
      authorize Patient, :update?
    elsif current_user.patient?
      authorize Patient, :patient?
    else
      redirect_to '/404'
    end
  end
end
