class AdminService

  def self.create
    user = FactoryGirl.create :user,
      role:           :Admin,
      email:          Rails.application.secrets.admin_email,
      password:       Rails.application.secrets.admin_password,
      password_confirmation: Rails.application.secrets.admin_password
    user.confirm
  end
end
