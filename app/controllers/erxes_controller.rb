class ErxesController < ApplicationController
  layout 'providers_settings'
  before_action :check_role

  def edit
    @erx = current_user.provider.erx
  end

  def update
    erx = current_user.provider.erx
    if erx.update(erx_params)
      log 4, 1
      flash[:notice] = updation_notification(erx)
    else
      flash[:error] = erx.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  protected

  def erx_params
    params.require(:erx).permit(
      :clinic_id,
      :clinic_key,
      :api_url,
      :login_url
    )
  end

  def check_role
    authorize Provider, :main_provider?
  end
end