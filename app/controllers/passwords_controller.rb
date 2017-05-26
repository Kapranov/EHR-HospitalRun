class PasswordsController < Devise::PasswordsController

  def update
    user = User.where(reset_password_token: params[:user][:reset_password_token]).first
    if user.present?
      if params[:user][:reset_password_token] != user.reset_password_token
        flash[:error] = 'Reset password token is invalid'
        redirect_to :back
      elsif user.update(reset_password_token: nil, reset_password_sent_at: nil, password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
        sign_in(User, user)
        redirect_to new_user_session_path
      else
        flash[:error] = user.errors.full_messages.to_sentence
        redirect_to :back
      end
    else
      flash[:error] = 'User not found'
      redirect_to :back
    end
  end

  private

  def after_resetting_password_path_for(resource)
    new_user_session_path
  end
end
