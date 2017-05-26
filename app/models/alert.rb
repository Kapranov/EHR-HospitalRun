class Alert
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.rules
    [:ONE, :'ONE of each category', :'Two or More', :All]
  end

  field :name,             type: String
  field :description,      type: String
  field :resolution,       type: String
  field :bibliography,     type: String
  field :developer,        type: String
  field :funding_source,   type: String
  field :release_date,     type: Time
  field :active,           type: Boolean,   default: true
  field :rule,             type: Enum,      in: self.rules,            default: self.rules.first

  has_many    :triggers,   dependent: :destroy
  belongs_to  :provider

  attr_accessor :release_date_date, :release_date_time

  before_validation :set_datetimes
  after_initialize  :get_datetimes

  def active?
    active
  end

  private

  def get_datetimes
    self.release_date ||= Time.now

    self.release_date_date ||= self.release_date.to_date.to_s(:frontend_date)
    self.release_date_time ||= "#{'%02d' % self.release_date.to_time.hour}:#{'%02d' % self.release_date.to_time.min}"
  end

  def set_datetimes
    self.release_date = "#{Date.strptime(self.release_date_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.release_date_time}".to_time
  end

end
