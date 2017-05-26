class FamilyHealthHistoriesController < ApplicationController
  before_action :check_role, :find_past_medical_history
  before_action :set_collections, only: [:new, :edit]
  before_action :prepare_params,  only: [:create, :update]
  before_action :find_family_health_history, only: [:edit, :update, :destroy_dx]

  def new
    @family_health_history = FamilyHealthHistory.new
  end

  def create
    family_health_history = FamilyHealthHistory.create(family_health_history_params)
    if family_health_history.persisted?
      create_dxes(family_health_history) if params[:family_health_history][:dx].present?
      log 1, 0, @past_medical_history.patient.try(:id)
      flash[:notice] = creation_notification(family_health_history)
      redirect_to patient_treatments_path
    else
      flash[:error] = family_health_history.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def edit

    @dxes = @family_health_history.all_dxes
  end

  def update
    if @family_health_history.update(family_health_history_params)
      create_dxes(@family_health_history) if params[:family_health_history][:dx].present?
      log 1, 1, @past_medical_history.patient.try(:id)
      flash[:notice] = updation_notification(@family_health_history)
      redirect_to patient_treatments_path
    else
      flash[:error] = @family_health_history.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def destroy_dx
    @family_health_history.destroy_dx(params[:dx_id])
    render nothing: true
  end

  protected

  def create_dxes(history)
    dxes = params[:family_health_history][:dx][:new]
    dxes.each do |_, p|
      [:onset_at].each { |field| p[field] = params[field].to_time }
      history.add_dx Dx.create(dx_params(p))
    end if dxes.present? && dxes.any?
  end

  def family_health_history_params
    params.require(:family_health_history).permit(
      :first_name,
      :last_name,
      :relationship,
      :birth_at,
      :birth_at_date,
      :birth_at_time,
      :age,
      :deceased,
      :dxes,
      :notes
    ).merge(past_medical_history_id: @past_medical_history.id)
  end

  def dx_params(p)
    p.permit(
      :onset_at,
      :snomed_id
    )
  end

  def find_past_medical_history
    @past_medical_history = PastMedicalHistory.find(params[:past_medical_history_id] || params[:family_health_history][:past_medical_history_id])
  end

  def check_role
    authorize PastMedicalHistory, :update?
  end

  def set_collections
    @relationships = FamilyHealthHistory.relationships
  end

  def prepare_params
    [:age].each      { |field| params[:family_health_history][field] = params[:family_health_history][field].to_i }
  end

  def find_family_health_history
    @family_health_history = @past_medical_history.family_health_histories.find(params[:id])
  end
end