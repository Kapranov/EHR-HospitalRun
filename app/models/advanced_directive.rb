class AdvancedDirective
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :record_date,  type: Time
  field :notes,        type: Text

  belongs_to :patient

  before_validation :set_datetimes
  after_initialize :get_datetimes

  attr_accessor :record_date_date, :record_date_time

  private

  def get_datetimes
    self.record_date ||= Time.now

    self.record_date_date ||= self.record_date.to_date.to_s(:frontend_date)
    self.record_date_time ||= "#{'%02d' % self.record_date.to_time.hour}:#{'%02d' % self.record_date.to_time.min}"
  end

  def set_datetimes
    self.record_date = "#{Date.strptime(self.record_date_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.record_date_time}".to_time
  end
end