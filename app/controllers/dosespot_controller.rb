class DosespotController < ApplicationController
  before_action :find_patient

  def sync_allergies
    @patient.try(:dosespot).try(:sync_allergies, current_user.provider.id)
    render nothing: true
  end

  def sync_medications
    @patient.try(:dosespot).try(:sync_medications, current_user.provider.id)
    render nothing: true
  end

  private

  def find_patient
    @patient = current_user.main_provider.patients.where(id: params[:patient_id]).try(:first)
  end
end