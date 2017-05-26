class PracticesController < ApplicationController
  before_action proc { authorize :practice, :create? }, only: [:new, :create]
  before_action proc { authorize :practice, :update? }, only: [:edit, :update, :admin, :activate]

  before_action :find_provider,  only: [:edit, :update, :admin, :activate]
  before_action :prepare_params, only: [:update]

  def new
    @user     = User.new
    @provider = Provider.new
  end

  def create
    code = Activation.code
    user     = User.create(user_params.merge({password: code, password_confirmation: code, role: :Provider}))
    provider = Provider.create(provider_params.merge({user_id: user.id, provider_id: current_user.provider.id }))
    if user.persisted? && provider.persisted?
      user.send_confirmation_instruction
      flash[:notice] = 'User created successfully'
      redirect_to settings_add_user_added_practice_path(id: user.id, code: code)
    else
      flash[:error] = user.errors.full_messages.to_sentence     if user.errors.any?
      flash[:error] = provider.errors.full_messages.to_sentence if provider.errors.any?
      user.destroy     if provider.persisted?
      provider.destroy if user.persisted?
      remote_redirect_to settings_practice_path
    end
  end

  def edit
    @locations = current_user.provider.locations
  end

  def update
    user = @provider.user
    if user.update(user_params) && @provider.update(provider_params)
        flash[:notice] = updation_notification(@provider)
        remote_redirect_to settings_practice_path
    else
      flash[:error] = user.errors.full_messages.to_sentence if user.errors.any?
      flash[:error] = @provider.errors.full_messages.to_sentence if user.errors.any?
      redirect_to edit_practice_path(@provider)
    end
  end

  def activate
    if params[:active] == 'true'
      @provider.activate
    else
      @provider.deactivate
    end
    render nothing: true
  end

  def admin
    @provider.update(admin: params[:admin])
    render nothing: true
  end

  def change_password
    if current_user.update_password(change_params)
      flash[:notice] = 'Password updated successfully'
    else
      flash[:error] = current_user.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  private

  def find_provider
    id = params[:id].present? ? params[:id] : (params[:provider].present? ? params[:provider][:id] : params[:user][:provider][:id] )
    @provider = current_user.provider.find_provider(id)
  end

  def change_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def prepare_params
    params[:user][:provider][:expiration_date] = params[:user][:provider][:expiration_date].try(:to_time)
  end

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :confirmed_at,
      :role
    )
  end

  def provider_params
    params.require(:user).require(:provider).permit(
      :practice_role,
      :provider_id,
      :title,
      :first_name,
      :middle_name,
      :last_name,
      :active,
      :degree,
      :speciality,
      :secondary_speciality,
      :dental_licence,
      :street_address,
      :suit_apt_number,
      :city,
      :state,
      :zip,
      :practice_street_address,
      :practice_suit_apt_number,
      :practice_city,
      :practice_state,
      :practice_zip,
      :expiration_date,
      :expiration_date_date,
      :expiration_date_time,
      :ein_tin,
      :npi,
      :dea,
      :upin,
      :nadean,
      :accepting_patient,
      :enable_online_booking,
      :biography,
      :primary_phone_code,
      :primary_phone_tel,
      :mobile_phone_code,
      :mobile_phone_tel,
      :primary_phone,
      :mobile_phone,
      :alt_email,
      :username,
      :profile_image
    )
  end
end
