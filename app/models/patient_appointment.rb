class PatientAppointment
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.appointment_types
    [
        :'Consultation',
        :'Crown/Bridge Delivery',
        :'Crown/Bridge Prep',
        :'Emergency',
        :'Endo',
        :'New Patient',
        :'New Patient – Child',
        :'Oral Surgery',
        :'Prophy Appointment',
        :'Prophy-Child',
        :'Prophy/Regular Appointment',
        :'Regular Appointment'
    ]
  end

  field  :date,             type: Time
  field  :location,         type: String
  field  :appointment_type, type: Enum, in: self.appointment_types, default: self.appointment_types.first
  field  :note,             type: Text
  field  :phone,            type: String
  field  :email,            type: String

  belongs_to :provider
  belongs_to :patient

  before_validation :phony_normalize
  before_validation :set_datetimes
  after_create :create_sms
  after_initialize :get_datetimes

  attr_accessor :datetime_date, :datetime_time
  attr_accessor :phone_code, :phone_tel

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
    self.date ||= Time.now

    self.datetime_date ||= self.date.to_date.to_s(:frontend_date)
    self.datetime_time ||= "#{'%02d' % self.date.to_time.hour}:#{'%02d' % self.date.to_time.min}"
  end

  def set_datetimes
    self.date = "#{Date.strptime(self.datetime_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.datetime_time}".to_time
  end

  def create_sms
    body = "New appointment #{appointment_type.try(:appt_type)} created on #{date.try(:strftime, '%Y-%m-%d %H:%m')} #{note}"
    TextMessage.create(to: provider.try(:primary_phone), body: body)
  end
end
