class DiagnosesController < ApplicationController
  before_action :check_role_show, only: [:index]
  before_action :check_role, :prepare_params, only: [:create, :update]
  before_action :find_patient,    only: [:index, :create, :update, :form, :education_materials, :add_education_material]

  def index
  end

  def create
    diagnosis = Diagnosis.create(diagnosis_params)
    if diagnosis.persisted?
      log 1, 0, @patient.try(:id)
      flash[:notice] = creation_notification(diagnosis)
      redirect_to show_patient_patient_treatments_path(id: @patient.id)
    else
      flash[:error] = diagnosis.errors.full_messages.to_sentence
      redirect_to form_diagnoses_path(patient_id: @patient.id, snomed_id: params[:diagnosis][:snomed_id])
    end
  end

  def update
    diagnosis = @patient.diagnoses.find(params[:id])
    if diagnosis.update(diagnosis_params)
      log 1, 1, @patient.try(:id)
      flash[:notice] = updation_notification(diagnosis)
      redirect_to show_patient_patient_treatments_path(id: @patient.id)
    else
      flash[:error] = diagnosis.errors.full_messages.to_sentence
      redirect_to form_diagnoses_path(id: diagnosis.id, patient_id: @patient.id, snomed_id: params[:diagnosis][:snomed_id])
    end
  end

  def form
    if params[:id].present?
      @diagnosis = @patient.diagnoses.find(params[:id])
      @snomed    = @diagnosis.snomed
    else
      @diagnosis = Diagnosis.new
      if params[:snomed_id]
        @snomed = Snomed.find(params[:snomed_id])
      end
    end
    @education_materials = @patient.education_materials
  end

  def reconciliation
    @exist_diagnosis    = Diagnosis.last_reconciliation(params[:patient_id])
    @referral_diagnoses = @exist_diagnosis.find_referral if @exist_diagnosis.present?
  end

  def previous_reconciliation
    @exist_diagnosis    = Diagnosis.find(params[:id]).previous_reconciliation
    @referral_diagnoses = @exist_diagnosis.find_referral if @exist_diagnosis.present?
    render partial: 'diagnoses/reconciliation_diagnoses'
  end

  def confirm_reconciliation
    @exist_diagnosis    = Diagnosis.find(params[:id]).merge_reconciliation
    @referral_diagnoses = []
    render partial: 'diagnoses/reconciliation_diagnoses'
  end

  def education_materials
    @education_material = current_user.main_provider.education_materials.where(:code_id => params[:snomed_id]).try(:first)
  end

  # def add_education_material
  #   education_material_id, belongs_to = params[:education_material_id], (params[:belongs_to] == 'true')
  #   belongs_to ? @patient.add_education_material(education_material_id) : @patient.remove_education_material(education_material_id)
  #   render nothing: true
  # end

  protected

  def diagnosis_params
    params.require(:diagnosis).permit(
        :patient_id,
        :snomed_id,
        :start_date,
        :start_date_date,
        :start_date_time,
        :stop_date,
        :stop_date_date,
        :stop_date_time,
        :acute,
        :terminal,
        :note
    )
  end

  def prepare_params
    [:stop_date_date, :stop_date_time].each { |field| params[:diagnosis].delete(field) if params[:diagnosis][field].blank? }
  end

  def find_patient
    @patient = Patient.find(params[:diagnosis].present? ? params[:diagnosis][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize Diagnosis
  end

  def check_role_show
    authorize Diagnosis, :show?
  end
end