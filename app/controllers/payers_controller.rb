class PayersController < ApplicationController
  before_action :check_role, :find_patient

  def new
    @payer = Payer.new
  end

  def create
    payer = Payer.create(payer_params)
    if payer.persisted?
      params[:payer][:claim][:zip] = params[:payer][:claim][:zip].to_i
      claim = Claim.create(claim_params.merge({payer_id: payer.id}))
      if claim.persisted?
        log 3, 0, payer.patient.try(:id)
        flash[:notice] = creation_notification(payer)
        redirect_to new_insurance_path(patient_id: @patient.id)
      else
        flash[:error] = claim.errors.full_messages.to_sentence
        redirect_to new_payer_path(patient_id: @patient.id)
      end
    else
      flash[:error] = payer.errors.full_messages.to_sentence
      redirect_to new_payer_path(patient_id: @patient.id)
    end
  end

  def payers
    log 3, 3, @patient.try(:id)
    payers = if params[:part].present?
               @patient.payers.where(name: /^#{params[:part]}/)
             else
               @patient.payers.limit(10)
             end.map{ |payer| { full_name: payer.name, id: payer.id, plan: payer.plan } }
    payers = [{ id: 1, empty: true }] unless payers.any?
    render json: payers
  end

  protected

  def payer_params
    params.require(:payer).permit(
        :patient_id,
        :name,
        :plan,
        :plan_type
    )
  end

  def claim_params
    params.require(:payer).require(:claim).permit(
        :first_name,
        :middle_name,
        :last_name,
        :street_address1,
        :street_address2,
        :phone,
        :fax,
        :phone_code,
        :phone_tel,
        :fax_code,
        :fax_tel,
        :ext1,
        :ext2,
        :city,
        :state,
        :zip,
        :notes
    )
  end

  def find_patient
    @patient = Patient.find(params[:payer].present? ? params[:payer][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize :chart, :insurance_show?
  end
end