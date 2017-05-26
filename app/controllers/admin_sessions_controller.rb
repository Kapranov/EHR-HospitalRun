class AdminSessionsController < ActionController::Base
  layout 'admin'
  
  def sign_in
    @user = User.new
    @devise_mapping = Devise.mappings[:user]
  end
end