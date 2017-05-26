class Patient
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  include CarrierWave::NoBrainer
  include ActiveModel::Serializers::Xml

  include Notifiable

  include Patient::Educationable
  include Patient::HlMessage
  extend  Patient::Reportable

  def self.genders
    [:Male, :Female, :Other]
  end

  def self.preferred_languages
    [
      :'English (en)', :'Spanish (es)', :'German (de)', :'Russian (ru)'
    ]
  end

  def self.ethnicities
    [:'Hispanic or Latino', :'Not Hispanic or Latino', :'Patient declined to specify']
  end

  def self.immunization_registries
    [:NotSend, :Send, :NotSpecified]
  end

  def self.races
    { 'American Indian or Alaska Native' => :american_race,
      'Asian' => :asian_race,
      'Black or African American' => :african_race,
      'Native Hawaiian or other Pacific Islander' => :hawaiian_race,
      'White' => :white_race,
      'Declined to Specify / Undetermined' => :undetermined_race }
  end

  def self.race_codes
    { american_race: '1002-5',
      asian_race: '2028-9',
      african_race: '2054-5',
      hawaiian_race: '2076-8',
      white_race: '2106-3',
      undetermined_race: '' }
  end

  def self.hl_ethnicity_codes
    { :'Hispanic or Latino' => 'H',
      :'Not Hispanic or Latino' => 'N',
      :'Patient declined to specify' => 'U'}
  end

  def self.ethnicity_codes
    { :'Hispanic or Latino' => '2135-2',
      :'Not Hispanic or Latino' => '2186-5' }
  end

  def self.preferred_contacts
    { 'Email' => :email,
      'Cell Phone' => :mobile_phone,
      'Home Phone' => :primary_phone,
      'Work Phone' => :work_phone,
      'Patient declined to specify' => :declined }
  end

  field :created_by_id,               type: String
  field :first_name,                  type: String #,       validates: { format: { with: /\A[A-Z][a-z\']+\z/ } },   max_length: 35
  field :middle_name,                 type: String #,     validates: { format: { with: /\A[A-Z][A-z\-\']+\z/ } }, max_length: 35
  field :last_name,                   type: String #,       validates: { format: { with: /\A[A-Z][A-z\-\']+\z/ } }, max_length: 35
  field :birth,                       type: Time
  field :gender,                      type: Enum,         in: self.genders,                 default: self.genders.first
  field :primary_phone,               type: String
  field :mobile_phone,                type: String
  field :work_phone,                  type: String
  field :preferred_contact,           type: String
  field :code,                        type: Integer
  field :social_number,               type: String
  field :active,                      type: Boolean,                                        default: true
  field :declined_portal_access,      type: Boolean
  field :preferred_language,          type: String
  field :ethnicity,                   type: Enum,         in: self.ethnicities,             default: self.ethnicities.first
  field :american_race,               type: Boolean
  field :asian_race,                  type: Boolean
  field :african_race,                type: Boolean
  field :hawaiian_race,               type: Boolean
  field :white_race,                  type: Boolean
  field :undetermined_race,           type: Boolean
  field :email_reminder,              type: Boolean
  field :sms_reminder,                type: Boolean
  field :immunization_registry,       type: Enum,         in: self.immunization_registries, default: self.immunization_registries.first
  field :ext,                         type: String
  field :street_address,              type: String #,       validates: { format: { with: /\A[0-9A-z\-.\/ ]+\z/ } }, max_length: 35
  field :city,                        type: String
  field :state,                       type: String
  field :zip,                         type: String
  field :profile_image,               type: String
  field :dosespot_patient_id,         type: Integer
  mount_uploader :profile_image, ImageUploader

  has_many    :patient_appointments
  has_many    :appointments
  has_many    :block_outs,           dependent: :destroy
  has_many    :payers
  has_many    :tooth_tables,         dependent: :destroy
  has_many    :diagnoses,            dependent: :destroy
  has_many    :allergies,            dependent: :destroy
  has_many    :insurances,           dependent: :destroy
  has_many    :smoking_statuses,     dependent: :destroy
  has_many    :immunizations,        dependent: :destroy
  has_many    :encounters,           dependent: :destroy
  has_many    :text_messages
  has_many    :email_messages
  has_many    :representatives,      dependent: :destroy
  has_many    :procedures,           dependent: :destroy
  has_many    :amendments,           dependent: :destroy
  has_many    :patient_education_materials
  has_many    :education_materials, through: :patient_education_materials
  has_many    :lab_orders,           dependent: :destroy
  has_many    :lab_results,          dependent: :destroy
  has_many    :image_orders,         dependent: :destroy
  has_one     :emergency_contact,    dependent: :destroy
  has_one     :next_kin,             dependent: :destroy
  has_one     :guarantor,            dependent: :destroy
  has_one     :past_medical_history, dependent: :destroy
  has_one     :advanced_directive,   dependent: :destroy
  has_one     :dosespot,             dependent: :destroy
  has_one     :secure_question,      dependent: :destroy
  has_one     :image_result,         dependent: :destroy
  belongs_to  :user
  belongs_to  :provider
  belongs_to  :created_by,           foreign_key: :created_by_id, class_name: Provider

  before_validation :set_phones, :phony_normalize, :set_datetimes
  after_create      :create_help_models, :create_teeth, :send_create_sms, :create_dosespot, :switch_off_2fa
  after_update      :send_update_sms, :update_dosespot
  after_initialize  :get_phones, :get_datetimes

  attr_accessor :primary_phone_code, :primary_phone_tel
  attr_accessor :mobile_phone_code,  :mobile_phone_tel
  attr_accessor :work_phone_code,    :work_phone_tel
  attr_accessor :start_date_date,    :start_date_time
  attr_accessor :birth_date,         :birth_time

  def full_name
    "#{first_name} #{last_name}"
  end

  def age
    now = Time.now.utc.to_date
    birth.present? ? now.year - birth.year - (birth.to_date.change(:year => now.year) > now ? 1 : 0) : nil
  end

  def race
    Patient.races.select{ |_, meth| meth == Patient.races.values.find{ |v| method(v).call } }.keys[0]
  end

  def race_code
    Patient.race_codes[Patient.races.select{ |_, meth| meth == Patient.races.values.find{ |v| method(v).call } }.values[0]]
  end

  def ethnicity_code
    Patient.ethnicity_codes[ethnicity]
  end

  def hl_ethnicity_code
    Patient.hl_ethnicity_codes[ethnicity]
  end

  def language_code
    if preferred_language
      Language.where(name: preferred_language).try(:first).try(:alpha3) || 'en-US'
    else
      'en-US'
    end
  end

  def gender_code
    gender.try(:to_s).try(:first).try(:upcase)
  end

  def status
    active ? 'ACTIVE' : 'INACTIVE'
  end

  def birth_to_s
    birth.try(:strftime, Date::DATE_FORMATS[:dosespot])
  end

  def preferred_contact_value
    if preferred_contact.present? && Patient.preferred_contacts.has_value?(preferred_contact.to_sym)
      case preferred_contact.to_sym
        when :email
          user.no_email ? '' : user.email
        when :declined
          nil
        else
          method(preferred_contact).call
      end
    else
      ''
    end
  end

  def medications
    Medication.where(:diagnosis_id.in => diagnoses.map(&:id))
  end

  private

  def get_phones
    if self.primary_phone.present?
      self.primary_phone_code = self.primary_phone[2..4]
      self.primary_phone_tel = self.primary_phone[5..self.primary_phone.size-1]
    end
    if self.mobile_phone.present?
      self.mobile_phone_code = self.mobile_phone[2..4]
      self.mobile_phone_tel = self.mobile_phone[5..self.mobile_phone.size-1]
    end
    if self.work_phone.present?
      self.work_phone_code = self.work_phone[2..4]
      self.work_phone_tel = self.work_phone[5..self.work_phone.size-1]
    end
  end

  def set_phones
    self.primary_phone = [self.primary_phone_code, self.primary_phone_tel].join
    self.mobile_phone = [self.mobile_phone_code, self.mobile_phone_tel].join
    self.work_phone = [self.work_phone_code, self.work_phone_tel].join
  end

  def phony_normalize
    self.mobile_phone  = PhonyRails.normalize_number(mobile_phone,  default_country_code: 'US')
    self.primary_phone = PhonyRails.normalize_number(primary_phone, default_country_code: 'US')
    self.work_phone    = PhonyRails.normalize_number(work_phone,    default_country_code: 'US')
  end

  def get_datetimes
    self.birth ||= Time.now

    self.birth_date ||= self.birth.to_date.to_s(:frontend_date)
    self.birth_time ||= "#{'%02d' % self.birth.to_time.hour}:#{'%02d' % self.birth.to_time.min}"
  end

  def set_datetimes
    self.birth = "#{Date.strptime(self.birth_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.birth_time}".to_time
  end

  def create_help_models
    [EmergencyContact, NextKin, Guarantor,
     AdvancedDirective, PastMedicalHistory,
     SmokingStatus, SecureQuestion, ImageResult].each { |klass| klass.create(patient_id: id) }
  end

  def create_teeth
    tooth_table_ids = ToothTable.insert_all(32.times.map{ |i| { patient_id: id, tooth_num: i + 1 }})
    attrs = tooth_table_ids.map{ |id| { tooth_table_id: id } }
    [Mgl, Cal, Gm, Pd].each do |klass|
      klass.insert_all(attrs.each{ |attr| attr[:field_name] = klass.to_s })
    end
  end

  def send_create_sms
    body = "New patient #{full_name} was created"
    TextMessage.create(to: provider.try(:primary_phone), body: body)
  end

  def send_update_sms
    body = "Patient #{full_name} was updated"
    TextMessage.create(to: provider.try(:primary_phone), body: body)
  end

  def create_dosespot
    Dosespot.create(dosespot_params)
  end

  def update_dosespot
    dosespot.update(dosespot_params) if dosespot.present?
  end

  def dosespot_params
    {
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      birth: birth.strftime(Date::DATE_FORMATS[:dosespot]),
      gender: (([:Male, :Female].include? gender) ? gender.to_s : 'Unknown'),
      social_number: social_number,
      first_address: street_address,
      city: city,
      state: state,
      zip: zip.to_s.rjust(5, '0'),
      patient_id: id
    }
  end

  def switch_off_2fa
    user.update(two_factor: false) if user.present?
  end
end
