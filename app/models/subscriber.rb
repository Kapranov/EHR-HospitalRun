class Subscriber
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.genders
    [:Male, :Female, :Other]
  end

  field :first_name,     type: String
  field :middle_name,    type: String
  field :last_name,      type: String
  field :birth,          type: Time
  field :gender,         type: Enum,  in: self.genders, default: self.genders.first
  field :social_number,  type: String
  field :phone,          type: String
  field :street_address, type: String
  field :city,           type: String
  field :state,          type: String
  field :zip,            type: String

  belongs_to :insurance

  before_validation :set_phones
  before_validation :phony_normalize
  before_validation :set_datetimes
  after_initialize :get_phones
  after_initialize :get_datetimes

  attr_accessor :phone_code, :phone_tel
  attr_accessor :birth_date, :birth_time

  private

  def get_phones
    if self.phone.present?
      self.phone_code = self.phone[2..4]
      self.phone_tel = self.phone[4..self.phone.size-1]
    end
  end

  def set_phones
    self.phone = [self.phone_code, self.phone_tel].join
  end

  def phony_normalize
    self.phone = PhonyRails.normalize_number(phone,  default_country_code: 'US')
  end

  def get_datetimes
    self.birth ||= Time.now

    self.birth_date ||= self.birth.to_date.to_s(:frontend_date)
    self.birth_time ||= "#{'%02d' % self.birth.to_time.hour}:#{'%02d' % self.birth.to_time.min}"
  end

  def set_datetimes
    self.birth = "#{Date.strptime(self.birth_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.birth_time}".to_time
  end
end
