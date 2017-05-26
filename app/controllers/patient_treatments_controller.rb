require 'net/http'
require 'uri'

class PatientTreatmentsController < ApplicationController
  layout 'providers_patient_treatments'

  before_action :check_role
  before_action :prepare_params, only: [
    :show_patient,
    :show_patient_chart,
    :show_patient_dental_chart,
    :show_patient_perio_chart,
    :show_patient_profile,
    :show_patient_insurance,
    :show_patient_erx,
    :show_patient_amendments,
    :download_xml
  ]

  def index
    @patients = current_user.provider.main_provider.patients.where(active: true).paginate(page: params[:page], per_page: 10)
  end

  def search_patients
    patients = current_user.provider.main_provider.patients.where(or: [{first_name: /^#{params[:part].downcase.titleize}/}, {last_name: /^#{params[:part].downcase.titleize}/}]).paginate(page: params[:page], per_page: 10)
    render partial: 'patient_treatments/patients', locals: { patients: patients }, layout: nil
  end

  def active_patients
    if params[:active] == 'true'
      patients = current_user.provider.main_provider.patients.paginate(page: params[:page], per_page: 10)
    else
      patients = current_user.provider.main_provider.patients.where(active: true).paginate(page: params[:page], per_page: 10)
    end
    render partial: 'patients', locals: { patients: patients }
  end

  def show_patient
    Phimail.recieve
  end

  def show_patient_chart
    @encounters           = @patient.encounters
    @diagnoses            = @patient.diagnoses
    @medications          = Medication.where(:diagnosis_id.in => @patient.diagnoses.map(&:id))
    allergies             = @patient.allergies
    @drugs                = allergies.drugs
    @foods                = allergies.foods
    @envs                 = allergies.envs
    @email_messages       = current_user.draft
    @appointments         = current_user.provider.appointments
    @smoking_statuses     = @patient.smoking_statuses.order_by(created_at: :desc)
    @past_medical_history = @patient.past_medical_history
    @advanced_directive   = @patient.advanced_directive
    @immunizations        = @patient.immunizations
    render partial: 'patient_treatments/chart'
  end

  def show_patient_dental_chart
    @encounters           = @patient.encounters
    @procedures           = Procedure.where(:tooth_table_id.in => @patient.tooth_tables.map(&:id))
    render partial: 'patient_treatments/dental_chart'
  end

  def show_patient_perio_chart
    @diactive_teeth = @patient.tooth_tables.where(active: false).map(&:tooth_num).to_json
    @top_teeth      = @patient.tooth_tables.where(:tooth_num.in => (1..16).to_a).order_by(:tooth_num).eager_load(:tooth_fields).to_a
    @bottom_teeth   = @patient.tooth_tables.where(:tooth_num.in => (17..32).to_a).order_by(tooth_num: :desc).eager_load(:tooth_fields).to_a
    @perio_update   = policy(:chart).perio_update?
    render partial: 'patient_treatments/perio_chart'
  end

  def show_patient_profile
    @languages            = Language.languages
    @ethnicities          = Patient.ethnicities
    @preferred_contacts   = Patient.preferred_contacts
    render partial: 'patient_treatments/profile'
  end

  def show_patient_insurance
    @insurances           = @patient.insurances
    render partial: 'patient_treatments/insurance'
  end

  def show_patient_erx
    @dosespot             = @patient.dosespot
    render partial: 'patient_treatments/erx'
  end

  def show_patient_amendments
    @amendments           = @patient.amendments
    render partial: 'patient_treatments/ammendment'
  end

  def registrate
    dosespot = Dosespot.find(params[:dosespot_id])
    dosespot.registrate
    render text: dosespot.patient_detail_url
  end

  private

  def prepare_params
    @patient = Patient.find(params[:id])
  end

  def check_role
    authorize Provider, :provider?
  end
end
