class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  include User::Emailable
  include User::WithoutEmail
  include User::IpLockable
  include User::Trialable

  def self.roles
    [:Provider, :Patient, :Admin, :Representative]
  end

  field :email,                   type: String,      uniq: true,     required: true
  field :encrypted_password,      type: String,                      required: true
  field :reset_password_token,    type: String
  field :reset_password_sent_at,  type: Time
  field :remember_created_at,     type: Time
  field :sign_in_count,           type: Integer
  field :current_sign_in_at,      type: Time
  field :last_sign_in_at,         type: Time
  field :current_sign_in_ip,      type: String
  field :last_sign_in_ip,         type: String
  field :ip_locked,               type: Boolean,      default: false
  field :role,                    type: Enum,         in: self.roles, default: :Provider,  required: true
  field :username,                type: String
  field :captcha,                 type: Integer
  field :locked,                  type: Boolean,      default: false
  field :confirmation_token,      type: String
  field :confirmed_at,            type: Time
  field :confirmation_sent_at,    type: Time
  field :unconfirmed_email,       type: String
  field :two_factor,              type: Boolean,      default: true
  field :no_email,                type: Boolean,      default: false

  validates_uniqueness_of :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, :password_confirmation, length: { minimum: 5 }, if: proc { encrypted_password_changed? }
  validates :password, confirmation: true

  devise :database_authenticatable, :registerable, :confirmable, :timeoutable, :recoverable,
         :rememberable

  has_one :provider,            dependent: :destroy
  has_one :user_patient,        dependent: :destroy, class_name: :Patient
  has_one :user_representative, dependent: :destroy, class_name: :Representative

  delegate :main_provider, to: :provider, allow_nil: true

  alias ip_locked? ip_locked
  alias send_confirmation_instruction send_on_create_confirmation_instructions

  public :send_confirmation_instruction

  before_validation :generate_captcha, on: [:create]

  def person
    case role
      when :Provider
        provider
      when :Patient
        user_patient
      when :Admin
        nil
      when :Representative
        user_representative.patient
    end
  end

  def patient
    if role == :Patient
      user_patient
    elsif role == :Representative
      user_representative.patient
    else
      nil
    end
  end

  def provider?
    role == :Provider
  end

  def patient?
    role == :Patient || role == :Representative
  end

  def to_label
    case role
      when :Provider
        provider.try(:to_label)
      when :Representative
        user_representative.patient.try(:full_name)
      when :Patient
        patient.try(:full_name)
      else
        email
    end
  end

  def active_for_authentication?
    super && active?
  end

  def active?
    case role
      when :Provider
        provider.authenticable?
      when :Representative
        user_representative.active
      when :Patient
        !no_email
      else
        true
    end
  end

  def inactive_message
    if !confirmed?
      :unconfirmed
    elsif trial?
      'Your 30-Day Trial version is finished'
    else
      'Sorry, this account has been deactivated'
    end
  end

  def user_id_for_email_messages
    role == :Representative ? user_representative.patient.user.id : id
  end

  def alt_email?
    provider.present? && provider.alt_email?
  end

  def update_password(params)
    email_param, password_param, password_confirmation_param = params['email'], params['password'], params['password_confirmation']
    user = User.where(email: email_param).first
    if user.present? && permission_valid?(email_param)
      user.update(password: password_param, password_confirmation: password_confirmation_param)
    else
      errors[:base] = 'Invalid params'
      false
    end
  end

  def send_on_create_confirmation_instructions
    # prevent sending confirmation instruction on create
  end

  private

  def generate_captcha
    self.captcha = Activation.code
  end

  def permission_valid?(email)
    case self.role
      when :Provider
        provider.practice_role == :Provider &&
            provider.all_providers.any? { |provider| provider.user.email == email } ||
            self.email == email
      else
        true
    end
  end
end
