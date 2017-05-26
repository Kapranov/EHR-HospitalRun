class Diagnosis
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  include Diagnos::Reconciliationable

  field :start_date,      type: Time
  field :stop_date,       type: Time,        default: Time.now
  field :acute,           type: Boolean
  field :terminal,        type: Boolean
  field :note,            type: Text
  field :referral,        type: Boolean,     default: false

  has_many   :medications, dependent: :destroy
  belongs_to :patient
  belongs_to :snomed

  default_scope { order(:created_at) }

  attr_accessor :start_date_date, :start_date_time
  attr_accessor :stop_date_date, :stop_date_time

  before_validation :set_datetimes
  after_initialize  :get_datetimes

  def to_label
    "#{snomed.try(:defaultTerm)}, #{snomed.try(:conceptId)}, START DATE: #{start_date.try(:strftime, Date::DATE_FORMATS[:dosespot])} - STOP DATE: #{stop_date.try(:strftime, Date::DATE_FORMATS[:dosespot])}"
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
    self.stop_date = "#{Date.strptime(self.stop_date_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.stop_date_time}".to_time
  end
end
