class AdminController < BaseAdminController

  def index
    @providers = Provider.providers
  end

  # def update
  #   admin = current_user
  #   if admin.update(admin_params)
  #     flash[:notice] = updation_notification(admin)
  #   else
  #     flash[:error] = admin.errors.full_messages.to_sentence
  #   end
  #   redirect_to admin_index_path
  # end
  #
  # protected
  #
  # def admin_params
  #   params.require(:user).permit(
  #     :email,
  #     :password,
  #     :password_confirmation
  #   )
  # end
end
