class PastMedicalHistoriesController < ApplicationController
  before_action :check_role, :find_patient

  def edit
    @past_medical_history    = @patient.past_medical_history
    @family_health_histories = @past_medical_history.family_health_histories
  end

  def update
    med_history = @patient.past_medical_history
    if med_history.update(past_medical_history_params)
      log 1, 1, @patient.try(:id)
      flash[:notice] = updation_notification_new(t('model_titles.past_medical_history'))
      redirect_to show_patient_patient_treatments_path(id: params[:patient_id])
    else
      flash[:error] = med_history.errors.full_messages.to_sentence
      redirect_to edit_past_medical_history_path(med_history, patient_id: params[:patient_id])
    end
  end

  protected

  def past_medical_history_params
    params.require(:past_medical_history).permit(
        :patient_id,
        :major_events,
        :ongoing_problems,
        :preventitive_care,
        :nutrition_history
    )
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def check_role
    authorize PastMedicalHistory, :update?
  end
end