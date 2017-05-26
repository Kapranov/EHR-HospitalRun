class EncountersController < ApplicationController
  before_action :check_role, :prepare_params,  only: [:create, :update]
  before_action :check_role_show, only: [:form, :encounters, :encounter_full_info]
  before_action :find_patient

  def create
    encounter = Encounter.create(encounter_params)
    if encounter.persisted?
      Procedure.find(params[:procedure_id]).update(encounter_id: encounter.id)
      vital = Vital.create(vital_params.merge({encounter_id: encounter.id}))
      if vital.persisted?
        if params[:encounter][:procedure_completeds].present?
          params[:encounter][:procedure_completeds].each do |_, proc_code|
            ProcedureCompleted.create(encounter_id: encounter.id, procedure_code: proc_code[:procedure_code])
          end
        end
        if params[:encounter][:procedure_recommends].present?
          params[:encounter][:procedure_recommends].each do |_, proc_code|
            ProcedureRecommended.create(encounter_id: encounter.id, procedure_code: proc_code[:procedure_code])
          end
        end
        log 1, 0, @patient.id
        flash[:notice] = creation_notification(encounter)
        redirect_to show_patient_patient_treatments_path(id: @patient.id)
      else
        flash[:error] = vital.errors.full_messages.to_sentence
        redirect_to form_encounters_path(patient_id: @patient.id)
      end
    else
      flash[:error] = encounter.errors.full_messages.to_sentence
      redirect_to form_encounters_path(patient_id: @patient.id)
    end
  end

  def update
    encounter = @patient.encounters.find(params[:id])
    if encounter.update(encounter_params)
      vital = Vital.find(params[:encounter][:vital][:id])
      if vital.update(vital_params)
        log 1, 1, @patient.id
        flash[:notice] = updation_notification(encounter)
        redirect_to show_patient_patient_treatments_path(id: params[:encounter][:patient_id])
      else
        flash[:error] = vital.errors.full_messages.to_sentence
        redirect_to form_encounters_path(id: encounter.id, patient_id: @patient.id)
      end
    else
      flash[:error] = encounter.errors.full_messages.to_sentence
      redirect_to form_encounters_path(id: encounter.id, patient_id: @patient.id)
    end
  end

  def form
    @encounter  = params[:id].present?  ?  @patient.encounters.find(params[:id]) : Encounter.new
    @vital      = params[:id].present?  ?  @encounter.vital : Vital.new
    @procedures = @patient.procedures.where(:tooth_table_id.in => @patient.tooth_tables.map(&:id))
                                     .order_by(:tooth_table_id, date_of_service: :desc)
                                     .map{ |p| [p.try(:to_label), p.try(:id)] }
  end

  def encounters
    selected_date = Date.parse(Date.strptime(params[:created_at], Date::DATE_FORMATS[:frontend_date]).to_s(:db))
    log 1, 3
    render json: @patient.encounters.where(created_at: selected_date.beginning_of_day..selected_date.end_of_day)
                                    .map{ |encounter| { created_at: encounter.created_at.strftime(Date::DATE_FORMATS[:dosespot]),
                                                        id: encounter.id }
                                    }
  end

  def encounter_full_info
    render partial: 'encounter_note', locals: { encounter: @patient.encounters.find(params[:id]), patient: @patient }
  end

  protected

  def encounter_params
    params.require(:encounter).permit(
        :provider_id,
        :patient_id,
        :serviced_at,
        :serviced_at_date,
        :serviced_at_time,
        :notes,
        :med_completed,
        :patient_education,
        :clinical_summary,
        :to_provider_id,
        :from_provider_id
    )
  end

  def vital_params
    params.require(:encounter).require(:vital).permit(
        :height_major,
        :height_minor,
        :weight,
        :units_system,
        :bp_left,
        :bp_right,
        :temp,
        :pulse,
        :rr,
        :sat,
        :temp_type,
        :ra_type,
        :blood
    )
  end

  def find_patient
    @patient = Patient.find(params[:encounter].present? ? params[:encounter][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize Encounter
  end

  def check_role_show
    authorize Encounter, :show?
  end

  def prepare_params
    [:to_provider_id, :from_provider_id].each { |field| params[:encounter][field] = nil if params[:encounter][field].blank? }
    [:height_major, :height_minor, :weight].each { |field| params[:encounter][:vital][field] = 0 if params[:encounter][:vital][field].blank? }
    [:temp_type].each { |field| params[:encounter][:vital].delete(field) if params[:encounter][:vital][field].blank? }
  end
end