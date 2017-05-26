class AdvancedDirectivesController < ApplicationController
  before_action :check_role
  before_action :find_patient, only: [:edit, :update]

  def edit
    @advanced_directive = @patient.advanced_directive
  end

  def update
    adv_directive = @patient.advanced_directive
    if adv_directive.update(adv_directive_params)
      log 1, 1, @patient.id
      flash[:notice] = updation_notification_new(t('model_titles.advanced_directive'))
      redirect_to show_patient_patient_treatments_path(id: params[:patient_id])
    else
      flash[:error] = adv_directive.errors.full_messages.to_sentence
      redirect_to edit_advanced_directive_path(adv_directive, patient_id: params[:patient_id])
    end
  end

  protected

  def adv_directive_params
    params.require(:advanced_directive).permit(
        :patient_id,
        :record_date,
        :record_date_date,
        :record_date_time,
        :notes
    )
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def check_role
    authorize AdvancedDirective, :update?
  end
end