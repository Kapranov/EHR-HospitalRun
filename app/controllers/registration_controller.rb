class RegistrationController < Devise::RegistrationsController
  before_action :prepare_params, :create_provider, only: [:create]
  before_action proc { @user = current_user.provider.find_provider(params[:id]).user }, only: [:edit], if: proc { current_user.role == :Provider }
  before_action :set_qr_urls, only: [:new, :complete]

  def create
    build_resource(sign_up_params)
    if resource.save
      reload
      redirect_to users_registrations_complete_path
    else
      @provider.destroy
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def complete
  end

  protected

  def prepare_params
    params[:user][:provider][:trial] = 30 # by default all providers are trial
  end

  def create_provider
    @provider = Provider.new(provider_params.merge({practice_role: :Provider}))
    begin
      @provider.save
    rescue TextMessage::TwillioError => e
      @provider.errors.add(:base, e.message)
    end
    if @provider.errors.any?
      flash[:errors] = @provider.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def reload
    @provider.bind_user(resource.id)
    after_sign_up
    resource.reload
  end

  def after_sign_up
    @provider.add_to_subscribe_list
  end

  def set_qr_urls
    @qr_google_play = RQRCode::QRCode.new(Rails.application.secrets.qrcode_google_play)
    @qr_app_store   = RQRCode::QRCode.new(Rails.application.secrets.qrcode_app_store)
  end

  def provider_params
    params.require(:user).require(:provider).permit(
      :title,
      :first_name,
      :middle_name,
      :last_name,
      :practice_role,
      :degree,
      :business_name,
      :speciality,
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
      :primary_phone_code,
      :primary_phone_tel,
      :mobile_phone_code,
      :mobile_phone_tel,
      :primary_phone,
      :mobile_phone,
      :alt_email,
      :username,
      :secondary_speciality,
      :dental_licence,
      :expiration_date,
      :ein_tin,
      :npi,
      :dea,
      :upin,
      :nadean,
      :active,
      :accepting_patient,
      :enable_online_booking,
      :biography,
      :profile_image,
      :remote_profile_image_url,
      :trial,
      :notify
    )
  end
end
