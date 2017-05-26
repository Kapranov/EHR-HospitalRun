class AppointmentsController < ApplicationController
  before_action :prepare_params, only: [:create, :update]

  def new
    authorize Appointment, :create?
    @appointment         = Appointment.new
    @providers           = current_user.provider.providers_collection
    @locations           = current_user.provider.locations_collection
    @rooms               = current_user.provider.rooms_collection
    @appointment_types   = current_user.provider.appointment_types_collection
    @durations           = Appointment.durations_collection
    @time_fors           = BlockOut.time_fors_collection
    @block_out_durations = BlockOut.durations_collection
  end

  def create
    authorize Appointment
    appointment = Appointment.create(appointment_params.merge({appointment_status_id: current_user.provider.appointment_statuses.first.try(:id)}))
    if appointment.persisted?
      remind(appointment) if params[:appointment][:reminder] == '1'
      log 0, 0, appointment.patient.try(:id)
      flash[:notice] = creation_notification_new(t('model_titles.appointment'))
      remote_redirect_to(request.referrer)
    else
      flash[:error] = appointment.errors.full_messages.to_sentence
      redirect_to new_appointment_path
    end
  end

  def update
    appointment = Appointment.find(params[:id])
    authorize appointment, :update?
    if appointment.update(appointment_params)
      flash[:notice] = updation_notification_new(t('model_titles.appointment'))
      if current_user.role == :Provider
        log 0, 1, appointment.patient.try(:id)
        remote_redirect_to(request.referrer)
      end
      if current_user.patient?
        remote_redirect_to(patients_path)
      end
    else
      flash[:error] = appointment.errors.full_messages.to_sentence
      redirect_to appointment_path(appointment)
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    authorize @appointment
    @rooms                = @appointment.provider.rooms_collection
    @patient_full_name    = @appointment.patient.full_name
    @patients             = @appointment.provider.patients_collection
    @providers            = @appointment.provider.providers_collection
    @referrals            = @appointment.provider.referrals_collection
    @appointment_statuses = @appointment.provider.appointment_statuses_collection
  end

  def destroy
    appointment = Appointment.find(params[:id])
    authorize appointment, :update?
    appointment.destroy
    log 0, 2, appointment.patient.try(:id)
    flash[:notice] = deletion_notification_new(t('model_titles.appointment'))
    redirect_to :back
  end

  def patients
    authorize Appointment, :show?
    patients = if params[:part].present?
                 current_user.provider.main_provider.patients.where(or: [{first_name: /^#{params[:part].downcase.titleize}/}, {last_name: /^#{params[:part].downcase.titleize}/}])
               else
                 current_user.provider.main_provider.patients.limit(10)
               end.map{ |patient|
                        { full_name: patient.full_name,
                          id:        patient.id,
                          email:     patient.user.present? && !patient.user.no_email ? patient.user.email : '',
                          phones:    [
                            "#{patient.primary_phone.present? ? "(#{patient.primary_phone_code}) #{patient.primary_phone_tel[0..2]}-#{patient.primary_phone_tel[3..-1]}" : ''}",
                            "#{patient.mobile_phone.present? ? "(#{patient.mobile_phone_code}) #{patient.mobile_phone_tel[0..2]}-#{patient.mobile_phone_tel[3..-1]}" : ''}"
                          ]
                        }
                      }
    log 0, 3
    render json: patients
  end

  def referrals
    authorize Appointment, :create?
    referrals = if params[:part].present?
                  current_user.provider.referrals.where(or: [{normal: /^#{params[:part]}/}, {last_name: /^#{params[:part]}/}])
                else
                  current_user.provider.referrals.limit(10)
                end.map{ |referral| { full_name: referral.full_name, id: referral.id } }
    log 0, 3
    render json: referrals
  end

  def reschedule
    authorize Appointment, :reschedule?
    appointment = Appointment.find(params[:id])
    appointment.update(appointment_status_id: current_user.provider.appointment_statuses.where(name: 'Reschedule').first.try(:id))
    log 0, 1, appointment.patient.try(:id)
    render nothing: true
  end

  private

  def prepare_params
    params[:appointment][:referral_id] = nil if params[:appointment][:referral_id].blank?
  end

  def remind(appointment)
    body = "New appointment #{appointment.appointment_type.appt_type} created on #{appointment.appointment_datetime.strftime('%Y-%m-%d %H:%m')} #{appointment.reason}"
    EmailMessage.create(to_id: appointment.patient.user.id, from_id: current_user.id, body: body, draft: false)
    TextMessage.create(to: current_user.provider.primary_phone, body: body)
  end

  def appointment_params
    params.require(:appointment).permit(
        :patient_id,
        :provider_id,
        :location_id,
        :room_id,
        :appointment_type_id,
        :reason,
        :appointment_datetime_date,
        :appointment_datetime_time,
        :duration,
        :contact_email,
        :contact_phone,
        :contact_phone_code,
        :contact_phone_tel,
        :reminder,
        :colour,
        :appointment_status_id,
        :referral_id
    )
  end

  def referral_params
    params.require(:appointment).require(:referral).permit(
        :normal,
        :middle_name,
        :last_name,
        :individual_npi,
        :speciality,
        :phone,
        :fax,
        :email
    )
  end
end
