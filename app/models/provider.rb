class Provider
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  include CarrierWave::NoBrainer

  include Notifiable

  include Provider::Activatable
  include Provider::Majorizable
  include Provider::SmsNotifiable
  include Provider::Subscribable
  include Provider::Trialable

  include Provider::Defaults::Alerts

  extend  Collectionable # must go after module Majorizable
  extend  Searchable     # must go after module Majorizable

  def self.titles
    [:Mr, :Ms, :Dr]
  end

  def self.degrees
    [
      :'DDS',
      :'DMD',
      :'MD',
      :'DO',
      :'RDH',
      :'N/A Degree'
    ]
  end

  def self.specialities
    [
      :'Dentistry',
      :'Endodontics',
      :'Oral and Maxillofacial Pathology',
      :'Oral and Maxillofacial Radiology',
      :'Oral and Maxillofacial Surgery',
      :'Orthodontics and Dentofacial Orthopedics',
      :'Pediatric Dentistry',
      :'Periodontics',
      :'Prosthodontics',
      :'N/A Speciality'
    ]
  end

  def self.practice_roles
    [:Provider, :Dentist, :Hygientist, :'Back Office', :'Front Desk']
  end

  def self.practice_roles_without_provider
    [:Dentist, :Hygientist, :'Back Office', :'Front Desk']
  end

  field :title,                       type: Enum,         in: self.titles,         default: self.titles.first
  field :first_name,                  type: String
  field :middle_name,                 type: String
  field :last_name,                   type: String
  field :practice_role,               type: Enum,         in: self.practice_roles, default: self.practice_roles[1]
  field :degree,                      type: Enum,         in: self.degrees,        default: self.degrees.first
  field :business_name,               type: String
  field :speciality,                  type: Enum,         in: self.specialities,   default: self.specialities.first
  field :street_address,              type: String
  field :suit_apt_number,             type: String
  field :city,                        type: String
  field :state,                       type: String
  field :zip,                         type: String
  field :practice_street_address,     type: String
  field :practice_suit_apt_number,    type: String
  field :practice_city,               type: String
  field :practice_state,              type: String
  field :practice_zip,                type: String
  field :primary_phone,               type: String
  field :mobile_phone,                type: String
  field :alt_email,                   type: String
  field :username,                    type: String
  field :secondary_speciality,        type: String
  field :dental_licence,              type: String
  field :expiration_date,             type: Time
  field :ein_tin,                     type: String
  field :npi,                         type: String
  field :dea,                         type: String
  field :upin,                        type: String
  field :nadean,                      type: String
  field :admin,                       type: Boolean,      default: false
  field :emergency_access,            type: Boolean,      default: false
  field :emergency_access_reason,     type: String
  field :biography,                   type: Text
  field :accepting_patient,           type: Boolean,      default: false
  field :enable_online_booking,       type: Boolean,      default: false
  field :profile_image,               type: String
  field :dosespot_user_id,            type: Integer,      default: 1052
  field :active,                      type: Boolean,      default: false
  field :trial,                       type: Integer
  field :notify,                      type: Boolean,      default: false
  mount_uploader :profile_image, ImageUploader

  has_many    :patients
  has_many    :own_patients,           foreign_key: :created_by_id,      class_name: Patient
  has_many    :providers
  has_many    :appointments,           dependent: :destroy
  has_many    :referrals,              dependent: :destroy
  has_many    :rooms,                  dependent: :destroy
  has_many    :appointment_types,      dependent: :destroy
  has_many    :appointment_statuses,   dependent: :destroy
  has_many    :patient_appointments,   dependent: :destroy
  has_many    :locations,              dependent: :destroy
  has_many    :encounters
  has_many    :text_messages
  has_many    :email_messages
  has_many    :insurances
  has_many    :contacts
  has_many    :permissions,            dependent: :destroy
  has_many    :alerts,                 dependent: :destroy
  has_many    :trigger_categories,     dependent: :destroy
  has_many    :education_materials,    dependent: :destroy
  has_many    :lab_orders,             dependent: :destroy
  has_many    :lab_results,            dependent: :destroy
  has_many    :image_orders,           dependent: :destroy
  has_many    :payments,               dependent: :destroy
  has_one     :schedule_general,       dependent: :destroy
  has_one     :erx,                    dependent: :destroy
  has_one     :payment_agreement_sign, dependent: :destroy
  has_one     :ehr_subscription,       dependent: :destroy
  belongs_to  :user
  belongs_to  :provider
  belongs_to  :location

  attr_accessor :primary_phone_code, :primary_phone_tel
  attr_accessor :mobile_phone_code,  :mobile_phone_tel

  validates :primary_phone, phone: true
  validates :mobile_phone,  phone: true

  alias_method :admin?,  :admin
  alias_method :active?, :active

  scope :active,         -> { where(active: true) }
  scope :pending,        -> { where(active: false) }
  scope :paid,           -> { where(:trial.undefined => true) }
  scope :providers,      -> { where(practice_role: :Provider) }

  select_collection [:main_provider, :appointment_statuses], :name
  select_collection [:main_provider, :appointment_types],    :appt_type
  select_collection [:main_provider, :locations],            :to_label
  select_collection [:main_provider, :patients],             :full_name
  select_collection :all_providers,                          :full_name,   :id,  :providers_collection
  select_collection [:main_provider, :trigger_categories],   :category
  select_collection [:main_provider, :referrals],            :full_name
  select_collection [:main_provider, :rooms],                :room
  select_collection :lab_orders,                             :order_num
  select_collection [:lab_results,   :without_order],        :order_name, :id, :results_without_order_collection

  search [:first_name, :last_name], :patients, [:main_provider, :patients]

  before_validation :set_phones, :phony_normalize
  before_validation :set_datetimes
  after_create      :create_help_models
  after_create      :create_permission_list, if: Proc.new { main_provider? }
  after_initialize  :get_phones
  after_initialize  :get_datetimes

  attr_accessor :expiration_date_date, :expiration_date_time

  def to_label
    "#{title} #{last_name} #{first_name}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def primary_phone_to_s
    "(#{primary_phone_code})#{primary_phone_tel[0..2]}-#{primary_phone_tel[3..-1]}"
  end

  def create_help_models
    [ScheduleGeneral, Erx, PaymentAgreementSign].each { |klass| klass.create(provider_id: id) }
    TriggerCategory.insert_all(TriggerCategory.categories.map { |category| { provider_id: id, category: category } }) if main_provider?
  end

  def authenticable?
    active? && (trial? ? trial_active? : true)
  end

  def alt_email?
    alt_email.present?
  end

  def subscribed?
    payment_agreement_sign.agreeded?
  end

  def bind_user(user_id)
    update(user_id: user_id)
    user.send_confirmation_instruction if user.present?
  end

  private

  def get_phones
    if primary_phone.present?
      self.primary_phone_code = primary_phone[2..4]
      self.primary_phone_tel = primary_phone[5..-1]
    end
    if mobile_phone.present?
      self.mobile_phone_code = mobile_phone[2..4]
      self.mobile_phone_tel = mobile_phone[5..-1]
    end
  end

  def set_phones
    self.primary_phone = [primary_phone_code, primary_phone_tel].join if primary_phone_tel.present?
    self.mobile_phone  = [mobile_phone_code, mobile_phone_tel].join   if mobile_phone_tel.present?
  end

  def phony_normalize
    self.primary_phone = PhonyRails.normalize_number(primary_phone, default_country_code: 'US')
    self.mobile_phone  = PhonyRails.normalize_number(mobile_phone,  default_country_code: 'US')
  end

  def get_datetimes
    self.expiration_date ||= Time.now

    self.expiration_date_date ||= self.expiration_date.to_date.to_s(:frontend_date)
    self.expiration_date_time ||= "#{'%02d' % self.expiration_date.to_time.hour}:#{'%02d' % self.expiration_date.to_time.min}"
  end

  def set_datetimes
    self.expiration_date = "#{Date.strptime(self.expiration_date_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.expiration_date_time}".to_time
  end

  def create_permission_list
    PermissionParser.set_default(self)
  end
end
