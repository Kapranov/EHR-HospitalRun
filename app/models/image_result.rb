class ImageResult
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  include ImageCollectionable

  field :schedule_at,        type: Time
  field :exam,               type: String
  field :requested_by,       type: String
  field :history,            type: String
  field :radiophamaceutical, type: String
  field :technique,          type: Text
  field :comparison,         type: Text
  field :findings,           type: Text
  field :impression,         type: Text

  belongs_to :patient

  before_validation :set_datetimes
  after_initialize :get_datetimes

  attr_accessor :schedule_at_date, :schedule_at_time

  private

  def get_datetimes
    self.schedule_at ||= Time.now

    self.schedule_at_date ||= self.schedule_at.to_date.to_s(:frontend_date)
    self.schedule_at_time ||= "#{'%02d' % self.schedule_at.to_time.hour}:#{'%02d' % self.schedule_at.to_time.min}"
  end

  def set_datetimes
    self.schedule_at = "#{Date.strptime(self.schedule_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.schedule_at_time}".to_time
  end
end
