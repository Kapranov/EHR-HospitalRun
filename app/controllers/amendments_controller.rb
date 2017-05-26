class AmendmentsController < ApplicationController
  before_action :check_role
  before_action :find_patient
  before_action :find_amendment,     only: [:edit,   :update, :destroy]
  before_action :set_collections,    only: [:new,    :edit]

  def new
    @amendment = Amendment.new
  end

  def create
    amendment = Amendment.create(amendment_params)
    if amendment.persisted?
      flash[:notice] = creation_notification(amendment)
      redirect_to patient_treatments_path(id: @patient.id)
    else
      flash[:error] = amendment.errors.full_messages.to_sentence
      redirect_to new_amendment_path(patient_id: @patient.id)
    end
  end

  def edit
  end

  def update
    if @amendment.update(amendment_params)
      flash[:notice] = updation_notification(@amendment)
      redirect_to patient_treatments_path(id: @patient.id)
    else
      flash[:error] = @amendment.errors.full_messages.to_sentence
      redirect_to edit_amendment_path(id: @amendment.id, patient_id: @patient.id)
    end
  end

  def destroy
    @amendment.destroy
    flash[:notice] = deletion_notification(@amendment)
    redirect_to patient_treatments_path(id: @patient.id)
  end

  protected

  def check_role
    authorize Provider, :admin?
  end

  def find_patient
    @patient = current_user.main_provider.patients.find(params[:amendment].present? ? params[:amendment][:patient_id] : params[:patient_id])
  end

  def find_amendment
    @amendment = @patient.amendments.find(params[:id])
  end

  def set_collections
    @statuses  = Amendment.statuses
    @sources   = Amendment.sources
    @attachment  = Attachment.new
    @attachments = @amendment.attachments if @amendment.present?
  end

  def amendment_params
    params.require(:amendment).permit(
        :patient_id,
        :requested_at,
        :requested_at_date,
        :requested_at_time,
        :accepted_at,
        :accepted_at_date,
        :accepted_at_time,
        :appended_at,
        :appended_at_date,
        :appended_at_time,
        :status,
        :source,
        :description,
        :note
    )
  end
end