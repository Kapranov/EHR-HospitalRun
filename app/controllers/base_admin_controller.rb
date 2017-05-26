class BaseAdminController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: Proc.new { redirect_to '/404', flash: { error: Rails.application.secrets.not_admin_notification } }

  before_action :check_role

  layout 'admin'

  protected

  def check_role
    authorize :admin, :admin?
  end
end
