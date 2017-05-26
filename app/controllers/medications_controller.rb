class MedicationsController < ApplicationController
  before_action :check_role_show,     only: [:index]
  before_action :check_role_provider, only: [:portions, :medications]
  before_action :find_patient,        only: [:index, :create, :update, :medications, :form,
                                             :reconciliation, :previous_reconciliation, :confirm_reconciliation]
  before_action :check_role,
                :find_diagnosis,      only: [:create, :update]

  def index
    @portions = Portion.all
  end

  def create
    medication = Medication.create(medication_params)
    if medication.persisted?
      log 1, 0, @patient.try(:id)
      flash[:notice] = creation_notification(medication)
      redirect_to form_diagnoses_path(id: @diagnosis.id, patient_id: @patient.id)
    else
      flash[:error] = medication.errors.full_messages.to_sentence
      redirect_to form_medications_path(patient_id: @patient.id, diagnosis_id: @diagnosis.id)
    end
  end

  def update
    medication = @diagnosis.medications.find(params[:id])
    if medication.update(medication_params)
      log 1, 1, @patient.try(:id)
      flash[:notice] = updation_notification(medication)
      redirect_to form_diagnoses_path(id: @diagnosis.id, patient_id: @patient.id)
    else
      flash[:error] = medication.errors.full_messages.to_sentence
      redirect_to form_medications_path(id: medication.id, patient_id: @patient.id, diagnosis_id: @diagnosis.id)
    end
  end

  def form
    @diagnosis  = @patient.diagnoses.find(params[:diagnosis_id])
    @medication = params[:id].present? ? Medication.find(params[:id]) : Medication.new
  end

  def reconciliation
    @exist_medication     = Medication.last_reconciliation(params[:patient_id])
    @referral_medications = @exist_medication.find_referral if @exist_medication.present?
  end

  def previous_reconciliation
    @exist_medication      = Medication.find(params[:id]).previous_reconciliation
    @referral_medications  = @exist_medication.find_referral if @exist_medication.present?
    render partial: 'medications/reconciliation_medications'
  end

  def confirm_reconciliation
    @exist_medication      = Medication.find(params[:id]).merge_reconciliation
    @referral_medications  = []
    render partial: 'medications/reconciliation_medications'
  end

  def portions
    log 1, 3
    render json: if params[:part].present?
                   Portion.where(drug: /^#{params[:part]}/)
                 else
                   Portion.limit(10)
                 end.map{ |portion| { full_name: "#{portion.drug} #{portion.dose} #{portion.instruction}", id: portion.id } }
  end

  def medications
    log 1, 3, @patient.try(:id)
    render json: if params[:part].present?
                   @patient.medications.where(:portion_id.in => Portion.where(drug: /^#{params[:part]}/).map(&:id))
                 else
                   @patient.medications.limit(10)
                 end.map{ |med| { full_name: "#{med.portion.try(:drug)} #{med.portion.try(:dose)} #{med.portion.try(:instruction)}", id: med.id } }
  end

  protected

  def medication_params
    params.require(:medication).permit(
        :diagnosis_id,
        :shorthand,
        :signature,
        :portion_id,
        :start_date,
        :start_date_date,
        :start_date_time,
        :stop_date,
        :stop_date_date,
        :stop_date_time,
        :note
    )
  end

  def find_patient
    @patient = Patient.find(params[:medication].present? ? params[:medication][:patient_id] : params[:patient_id])
  end

  def find_diagnosis
    @diagnosis = @patient.diagnoses.find(params[:medication][:diagnosis_id]) if params[:medication][:diagnosis_id].present?
  end

  def check_role_provider
    authorize Provider, :provider?
  end

  def check_role
    authorize Medication
  end

  def check_role_show
    authorize Medication, :show?
  end
end