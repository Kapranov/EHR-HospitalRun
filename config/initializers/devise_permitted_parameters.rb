module DevisePermittedParameters
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters
  end

  protected

  def configure_permitted_parameters
	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(
      :email,
      :password,
      :password_confirmation
    )
    }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(
      :confirmation_token,
      provider_attributes: [
        :title,
        :last_name,
        :username,
        :profile_image,
        :remote_profile_image_url
      ])
    }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(
      :email,
      :password,
      :password_confirmation,
      provider_attributes: [
        :title,
        :first_name,
        :middle_name,
        :last_name,
        :degree,
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
        :remote_profile_image_url
      ])
    }
  end
end

DeviseController.send :include, DevisePermittedParameters
