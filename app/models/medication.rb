class Medication
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  include Medicat::Reconciliationable

  field :shorthand,              type: String
  field :signature,              type: Text
  field :start_date,             type: Time
  field :stop_date,              type: Time
  field :note,                   type: Text
  field :referral,               type: Boolean,     default: false

  field :dosespot_medication_id, type: String #
  field :source,                 type: String #

  belongs_to :diagnosis
  belongs_to :portion

  default_scope    { order(:created_at) }

  before_validation :set_datetimes
  after_initialize  :get_datetimes

  attr_accessor :start_date_date, :start_date_time
  attr_accessor :stop_date_date,  :stop_date_time

  def to_label
    "#{shorthand}, #{signature}, START DATE: #{start_date.try(:strftime, Date::DATE_FORMATS[:dosespot])} - END DATE: #{stop_date.try(:strftime, Date::DATE_FORMATS[:dosespot])}"
  end

  private

  def get_datetimes
    self.start_date ||= Time.now
    self.stop_date  ||= Time.now

    self.start_date_date ||= self.start_date.to_date.to_s(:frontend_date)
    self.start_date_time ||= "#{'%02d' % self.start_date.to_time.hour}:#{'%02d' % self.start_date.to_time.min}"

    self.stop_date_date ||= self.stop_date.to_date.to_s(:frontend_date)
    self.stop_date_time ||= "#{'%02d' % self.stop_date.to_time.hour}:#{'%02d' % self.stop_date.to_time.min}"
  end

  def set_datetimes
    self.start_date = "#{Date.strptime(self.start_date_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.start_date_time}".to_time
    self.stop_date  = "#{Date.strptime(self.stop_date_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.stop_date_time}".to_time
  end
end
