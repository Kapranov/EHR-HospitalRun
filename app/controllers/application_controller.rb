class ApplicationController < ActionController::Base
  include Pundit
  include AuditLoggable

  rescue_from Pundit::NotAuthorizedError, with: proc { redirect_to '/404' }
  auto_session_timeout Devise.timeout_in

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  layout 'authorization'

  protected

  def after_sign_in_path_for(resource)
    case current_user.role
      when :Provider
        providers_path
      when :Patient
        after_sign_in_path_for_patient
      when :Admin
        admin_index_path
      when :Representative
        patients_path
      else
        dashboard_index_path
    end
  end

  def after_sign_in_path_for_patient
    current_user.first_enter? ? secure_questions_path : patients_path
  end

  def remote_redirect_to(path)
    render js: "window.location='#{path}'"
  end

  def creation_notification(object)
    "#{object.class.to_s} #{Rails.application.secrets.create_notification}"
  end

  def creation_notification_new(model_title)
    "#{model_title} #{Rails.application.secrets.create_notification}"
  end

  def creation_notification_more(object)
    "#{Rails.application.secrets.create_notification_more_type} #{object.class.to_s} #{Rails.application.secrets.create_notification_more_message}"
  end

  def updation_notification(object)
    "#{object.class.to_s} #{Rails.application.secrets.update_notification}"
  end

  def updation_notification_new(model_title)
    "#{model_title} #{Rails.application.secrets.update_notification}"
  end

  def deletion_notification(object)
    "#{object.class.to_s} #{Rails.application.secrets.delete_notification}"
  end

  def deletion_notification_new(model_title)
    "#{model_title} #{Rails.application.secrets.delete_notification}"
  end
end
