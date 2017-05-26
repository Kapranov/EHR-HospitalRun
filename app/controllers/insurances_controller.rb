class InsurancesController < ApplicationController
  before_action :check_role, :find_patient
  before_action :prepare_params, only: [:create]

  def new
    @insurance = Insurance.new
  end

  def create
    insurance = Insurance.create(insurance_params)
    if insurance.persisted?
      employer = Employer.create(employer_params.merge({insurance_id: insurance.id}))
      subscriber = Subscriber.create(subscriber_params.merge({insurance_id: insurance.id}))
      if subscriber.persisted? && employer.persisted?
        log 3, 0, insurance.patient.try(:id)
        flash[:notice] = creation_notification(insurance)
        redirect_to show_patient_main_patient_treatments_path(id: params[:insurance][:patient_id])
      else
        flash[:error] = subscriber.errors.full_messages.to_sentence unless subscriber.persisted?
        flash[:error] = employer.errors.full_messages.to_sentence   unless employer.persisted?
        redirect_to new_insurance_path(patient_id: @patient.id)
      end
    else
      flash[:error] = insurance.errors.full_messages.to_sentence
      redirect_to new_insurance_path(patient_id: @patient.id)
    end
  end

  protected

  def prepare_params
    params[:insurance][:claim]          = params[:insurance][:claim].to_i
    params[:insurance][:copay_amount]   = params[:insurance][:copay_amount].to_i
    params[:insurance][:employer][:zip] = params[:insurance][:employer][:zip].to_i
    params[:insurance][:subscriber][:zip] = params[:insurance][:subscriber][:zip].to_i
  end

  def insurance_params
    params.require(:insurance).permit(
        :patient_id,
        :provider_id,
        :payer_id,
        :worker_compensation,
        :insurance_number,
        :relation,
        :effective_from,
        :effective_from_date,
        :effective_from_time,
        :effective_to,
        :effective_to_date,
        :effective_to_time,
        :copay_type,
        :copay_amount,
        :claim,
        :note,
        :active
    )
  end

  def employer_params
    params.require(:insurance).require(:employer).permit(
        :name,
        :phone,
        :phone_code,
        :phone_tel,
        :street_address,
        :city,
        :state,
        :zip
    )
  end

  def subscriber_params
    params.require(:insurance).require(:subscriber).permit(
        :first_name,
        :middle_name,
        :last_name,
        :birth,
        :gender,
        :social_number,
        :phone,
        :phone_code,
        :phone_tel,
        :street_address,
        :city,
        :state,
        :zip
    )
  end

  def find_patient
    @patient = Patient.find(params[:insurance].present? ? params[:insurance][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize :chart, :insurance_show?
  end
end