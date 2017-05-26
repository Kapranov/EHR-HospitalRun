class SyndromicSurveillancesController < ApplicationController
  before_action :check_role, :find_patient

  def index
  end

  private

  def find_patient
    @patient = current_user.main_provider.patients.find(params[:patient_id])
  end

  def check_role
    # authorize :calendar, :show?
  end
end
