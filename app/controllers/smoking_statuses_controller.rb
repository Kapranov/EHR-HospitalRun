class SmokingStatusesController < ApplicationController
  before_action :check_role
  before_action :find_patient,   only: [:new]

  def new
    @smoking_status = SmokingStatus.new
  end

  def create
    smoking_status = SmokingStatus.create(smoking_status_params)
    if smoking_status.persisted?
      log 1, 0, params[:smoking_status][:patient_id]
      flash[:notice] = creation_notification_new(t('model_titles.smoking_status'))
      redirect_to show_patient_patient_treatments_path(id: params[:smoking_status][:patient_id])
    else
      flash[:error] = smoking_status.errors.full_messages.to_sentence
      redirect_to new_smoking_status_path(patient_id: params[:smoking_status][:patient_id])
    end
  end

  protected

  def smoking_status_params
    params.require(:smoking_status).permit(
        :patient_id,
        :status,
        :effective_from,
        :effective_from_date,
        :effective_from_time
    )
  end

  def find_patient
    @patient = Patient.find(params[:smoking_status].present? ? params[:smoking_status][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize SmokingStatus, :update?
  end
end