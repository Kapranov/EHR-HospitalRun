class DiagnosisCodesController < ApplicationController
  before_action :check_role_provider, only: [:diagnosis_codes]

  def diagnosis_codes
    log 1, 3
    render json: if params[:part].present?
                   DiagnosisCode.find_diagnosis_codes_by(params[:part])
                 else
                   DiagnosisCode.diagnosis_codes_first(10)
                 end.map{ |code| { id: code.id, full_name: code.description, code: code.code } }
  end

  protected

  def check_role_provider
    authorize Provider, :provider?
  end
end