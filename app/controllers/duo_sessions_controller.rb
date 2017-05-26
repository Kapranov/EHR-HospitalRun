class DuoSessionsController < Devise::SessionsController
  protect_from_forgery except: [:create]

  before_action :disable_emergency_access, only: [:destroy]
  before_action :set_qr_urls,              only: [:new]

  def second_step
    @user = User.where(email: params[:user][:email]).first
    if @user.present? && @user.valid_password?(params[:user][:password])
      if Rails.env == 'production' && @user.two_factor
        duo_params
        render 'devise/sessions/second_step'
      else
        finish_sign_in
        redirect_to after_sign_in_path_for(@user)
      end
    else
      flash[:error] = 'Wrong email or password'
      redirect_to :back
    end
  end

  def create
    @user = User.where(email: Duo::Auth.verify_response(params[:sig_response])).first
    if @user.present?
      finish_sign_in
      redirect_to after_sign_in_path_for(@user)
    else
      flash[:error] = 'User was not found'
      redirect_to :new_user_session
    end
  end

  def finish_sign_in
    sign_in(User, @user)
    update_ip if @user.role == :Patient && !@user.ip_locked?
  end

  def active
    render_session_status
  end

  def timeout
  end

  protected

  def duo_params
    @host        = Duo::Auth.host
    @sig_request = Duo::Auth.sign_request(@user.email)
    @back_url    = user_session_path
  end

  def update_ip
    current_user.update_ip(request.remote_ip)
  end

  def disable_emergency_access
    current_user.provider.update(emergency_access: false) if current_user.role == :Provider
  end

  def set_qr_urls
    @qr_google_play = RQRCode::QRCode.new(Rails.application.secrets.qrcode_google_play)
    @qr_app_store   = RQRCode::QRCode.new(Rails.application.secrets.qrcode_app_store)
  end
end