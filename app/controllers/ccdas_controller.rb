class CcdasController < ApplicationController
  before_action :check_role, :find_patient

  def new
    @ccda = Ccda.new
  end

  def create
    @ccda = Ccda.create(ccda_params)
    if @ccda.persisted?
      flash[:notice] = creation_notification(@ccda)
    else
      flash[:error]  = @ccda.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def download
    path = 'Patient.xml'
    @ccda = Ccda.new(ccda_params)
    File.open(path, 'w+') { |f| f.write(render_to_string(partial: 'ccdas/patient.xml' , layout: false)) }
    send_file path
  end

  def preview_xml
    @ccda = Ccda.new(ccda_params)
    render partial: 'ccdas/patient'
  end

  def preview_html
    @ccda = Ccda.new(ccda_params)
    @patient_info_fields = Ccda.patient_info_fields
    @basic_fields  = Ccda.basic_information_fields
    @encounters    = @ccda.value_of(Ccda.encounter_diagnoses_fields.first)
    @immunizations = @ccda.value_of(Ccda.immunizations_fields.first)
    @cog_statuses  = @ccda.value_of(Ccda.cognitive_status_fields.first)
    @fun_statuses  = @ccda.value_of(Ccda.functional_status_fields.first)
    @reasons       = @ccda.value_of(Ccda.reason_for_referral_fields.first)
    @instructions  = @ccda.value_of(Ccda.discharge_instructions_fields.first)
    @smoking_statuses = @ccda.value_of(Ccda.smoking_status_fields.first)
    @problems      = @ccda.value_of(Ccda.problems_dx_fields.first)
    @medications   = @ccda.value_of(Ccda.medications_fields.first)
    @allergies     = @ccda.value_of(Ccda.medication_allergies_fields.first)
    @labs          = @ccda.value_of(Ccda.laboratory_fields.first)
    @vitals        = @ccda.value_of(Ccda.vital_fields.first)
    @care_plans    = @ccda.value_of(Ccda.care_plan_fields.first)
    @procedures    = @ccda.value_of(Ccda.procedures_fields.first)
    @care_members  = @ccda.value_of(Ccda.care_team_members_fields.first)
  end

  private

  def ccda_params
    params.require(:ccda).permit(
        :patient_id,
        :identification,
        :contact_information,
        :basic_information,
        :encounter_diagnoses,
        :immunizations,
        :cognitive_status,
        :functional_status,
        :reason_for_referral,
        :discharge_instructions,
        :smoking_status,
        :problems_dx,
        :medications,
        :medication_allergies,
        :laboratory,
        :vital,
        :care_plan,
        :procedures,
        :care_team_members
    )
  end

  def find_patient
    @patient = current_user.main_provider.patients.find(params[:patient_id])
  end

  def check_role
    # authorize :calendar, :show?
  end
end
