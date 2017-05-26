class Admin::UsersController < BaseAdminController
  before_action :find_user,      only: [
                                        :edit,
                                        :update,
                                        :activate,
                                        :activated,
                                        :suspend,
                                        :delete_confirmation,
                                        :destroy,
                                        :pay,
                                        :trial
                                        ]

  before_action :set_password,   only: [:create]
  before_action :prepare_params, only: [:create, :update]

  def index
    @pending = Provider.providers.pending
    @active  = Provider.providers.active
    @paid    = Provider.providers.paid
  end

  def new
    @user     = User.new
    @provider = Provider.new
  end

  def create
    user = User.create(user_params.merge({role: :Provider}))
    provider = Provider.create(provider_params.merge({practice_role: :Provider, user_id: user.persisted? ? user.id : nil}))
    if user.persisted? && provider.persisted?
      flash[:notice] = creation_notification(provider)
      redirect_to admin_users_path
    else
      flash[:error] = user.errors.full_messages.to_sentence     unless user.persisted?
      flash[:error] = provider.errors.full_messages.to_sentence unless provider.persisted?
      redirect_to new_admin_user_path
    end
  end

  def edit
    @provider = @user.provider
  end

  def update
    provider = @user.provider
    if provider.update(provider_params)
      flash[:notice] = updation_notification(provider)
      redirect_to admin_users_path
    else
      flash[:error] = provider.errors.full_messages.to_sentence
      redirect_to edit_admin_user_path(@user)
    end
  end

  def activate
  end

  def activated
    @user.provider.activate
    redirect_by(params[:type])
  end

  def suspend
    @user.provider.deactivate
    redirect_by(params[:type])
  end

  def delete_confirmation
  end

  def destroy
    @user.destroy if @user.trial?
    redirect_by(params[:type])
  end

  def pay
    @user.provider.to_paid
    redirect_by(params[:type])
  end

  def trial
    @user.provider.to_trial
    redirect_by(params[:type])
  end

  protected

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation
    )
  end

  def provider_params
    params.require(:user).require(:provider).permit(
      :user_id,
      :title,
      :first_name,
      :middle_name,
      :last_name,
      :degree,
      :speciality,
      :secondary_speciality,
      :dental_licence,
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
      :primary_phone,
      :mobile_phone,
      :alt_email,
      :username,
      :profile_image
    )
  end

  def set_password
    password = params[:user][:password]
    if password.blank?
      password = Activation.code
      params[:user][:password] = password
    end
    params[:user][:password_confirmation] = password
  end

  def prepare_params
    params[:user][:provider][:zip]          = params[:user][:provider][:zip].to_i
    params[:user][:provider][:practice_zip] = params[:user][:provider][:practice_zip].to_i
  end

  def find_user
    @user = User.find(params[:id])
  end

  def redirect_by(path)
    remote_redirect_to case path
      when 'index'
        admin_index_path
      when 'users'
        admin_users_path
      else
        admin_users_path
    end
  end
end
