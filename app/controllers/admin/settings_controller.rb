class Admin::SettingsController < BaseAdminController
  def index
    @setting = AppSetting.first
  end

  def update
    @setting = AppSetting.first
    unless @setting.update(app_setting_params)
      flash[:error]  = @setting.errors.full_message.to_sentence
    end
    redirect_to :back
  end

  private

  def app_setting_params
    params.require(:app_setting).permit(:version)
  end
end
