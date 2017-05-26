class GuarantorsController < ApplicationController
  before_action :check_role, :find_patient

  def update
    guarantor = Patient.find(params[:guarantor][:patient_id]).guarantor
    if guarantor.update(guarantor_params)
      log 3, 1, @patient.id
      flash[:notice] = updation_notification(guarantor)
    else
      flash[:error] = guarantor.errors.full_messages.to_sentence
    end
    redirect_to show_patient_patient_treatments_path(id: @patient.id)
  end

  def guarantor
    log 3, 3
    render json: @patient.guarantor
  end

  protected

  def guarantor_params
    params.require(:guarantor).permit(
        :first_name,
        :middle_name,
        :last_name,
        :gender,
        :social_number,
        :birth,
        :birth_date,
        :birth_time,
        :relation,
        :phone,
        :phone_code,
        :phone_tel,
        :email,
        :street_address,
        :city,
        :state,
        :zip
    )
  end

  def find_patient
    @patient = Patient.find(params[:guarantor].present? ? params[:guarantor][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize :chart, :insurance_show?
  end
end