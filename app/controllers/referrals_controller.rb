class ReferralsController < ApplicationController
  before_action :check_role

  def new
    @referral = Referral.new
  end

  def create
    referral = Referral.create(referral_params.merge({provider_id: current_user.provider.id}))
    if referral.persisted?
      log 0, 0
      redirect_to new_appointment_path
    else
      flash[:error] = referral.errors.full_messages.to_sentence
      redirect_to new_referral_path
    end
  end

  private

  def referral_params
    params.require(:referral).permit(
      :provider_id,
      :normal,
      :middle_name,
      :last_name,
      :individual_npi,
      :speciality,
      :phone,
      :fax,
      :phone_code,
      :phone_tel,
      :fax_code,
      :fax_tel,
      :email
    )
  end

  def check_role
    authorize Appointment, :create?
  end
end
