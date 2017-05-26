class AllergiesController < ApplicationController
  before_action :check_role,   only: [:create, :update]
  before_action :find_patient

  def create
    allergy = Allergy.create(allergy_params)
    if allergy.persisted?
      log 1, 0, @patient.id
      flash[:notice] = creation_notification(allergy)
      redirect_to show_patient_patient_treatments_path(id: @patient.id)
    else
      flash[:error] = allergy.errors.full_messages.to_sentence
      redirect_to form_allergies_path(patient_id: @patient.id)
    end
  end

  def update
    allergy = @patient.allergies.find(params[:id])
    if allergy.update(allergy_params)
      log 1, 1, @patient.id
      flash[:notice] = updation_notification(allergy)
      redirect_to show_patient_patient_treatments_path(id: @patient.id)
    else
      flash[:error] = allergy.errors.full_messages.to_sentence
      redirect_to form_allergies_path(id: allergy.id, patient_id: @patient.id)
    end
  end

  def form
    @allergy = (params[:id].present? ? @patient.allergies.find(params[:id]) : Allergy.new)
  end

  def reconciliation
    @exist_allergy      = Allergy.last_reconciliation(params[:patient_id])
    @referral_allergies = @exist_allergy.find_referral if @exist_allergy.present?
  end

  def previous_reconciliation
    @exist_allergy      = Allergy.find(params[:id]).previous_reconciliation
    @referral_allergies = @exist_allergy.find_referral if @exist_allergy.present?
    render partial: 'allergies/reconciliation_allergies'
  end

  def confirm_reconciliation
    @exist_allergy      = Allergy.find(params[:id]).merge_reconciliation
    @referral_allergies = []
    render partial: 'allergies/reconciliation_allergies'
  end

  protected

  def allergy_params
    params.require(:allergy).permit(
        :patient_id,
        :allergen_type,
        :severity_level,
        :onset_at,
        :start_date,
        :start_date_date,
        :start_date_time,
        :active,
        :note
    )
  end

  def find_patient
    @patient = Patient.find(params[:allergy].present? ? params[:allergy][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize Allergy
  end
end