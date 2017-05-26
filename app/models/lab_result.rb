class LabResult
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :fasting,             type: String
  field :specimen,            type: String
  field :specimen_type,       type: String
  field :test_resported_at,   type: Time
  field :ordering_physician,  type: String
  field :npi,                 type: String

  field :order_name,          type: String
  field :order_address,       type: String
  field :collected_at,        type: Time
  field :received_at,         type: Time
  field :performing_name,     type: String
  field :performing_address,  type: String
  field :tested_at,           type: Time
  field :notes,               type: Text

  belongs_to :lab_order
  belongs_to :provider
  belongs_to :patient

  scope :without_order, ->(){ where(:lab_order_id.undefined => true) }

  before_validation :set_datetimes
  after_initialize  :get_datetimes

  attr_accessor :test_resported_at_date, :test_resported_at_time
  attr_accessor :collected_at_date,      :collected_at_time
  attr_accessor :received_at_date,       :received_at_time
  attr_accessor :tested_at_date,         :tested_at_time

  private

  def get_datetimes
    self.test_resported_at ||= Time.now
    self.collected_at ||= Time.now
    self.received_at ||= Time.now
    self.tested_at ||= Time.now

    self.test_resported_at_date ||= self.test_resported_at.to_date.to_s(:frontend_date)
    self.test_resported_at_time ||= "#{'%02d' % self.test_resported_at.to_time.hour}:#{'%02d' % self.test_resported_at.to_time.min}"

    self.collected_at_date ||= self.collected_at.to_date.to_s(:frontend_date)
    self.collected_at_time ||= "#{'%02d' % self.collected_at.to_time.hour}:#{'%02d' % self.collected_at.to_time.min}"

    self.received_at_date ||= self.received_at.to_date.to_s(:frontend_date)
    self.received_at_time ||= "#{'%02d' % self.received_at.to_time.hour}:#{'%02d' % self.received_at.to_time.min}"

    self.tested_at_date ||= self.tested_at.to_date.to_s(:frontend_date)
    self.tested_at_time ||= "#{'%02d' % self.tested_at.to_time.hour}:#{'%02d' % self.tested_at.to_time.min}"
  end

  def set_datetimes
    self.test_resported_at = "#{Date.strptime(self.test_resported_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.test_resported_at_time}".to_time
    self.collected_at = "#{Date.strptime(self.collected_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.collected_at_time}".to_time
    self.received_at = "#{Date.strptime(self.received_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.received_at_time}".to_time
    self.tested_at = "#{Date.strptime(self.tested_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.tested_at_time}".to_time
  end
end