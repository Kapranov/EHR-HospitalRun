class AuditLog
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.data_types
    [:Schedule, :Chart, :Profile, :Insurance, :Erx, :'Labs & Imaging', :Dosespot]
  end

  def self.actions
    [:Add, :Change, :Delete, :Query, :Print, :Copy]
  end

  field :data_type,         type: Enum,           in: self.data_types,         default: self.data_types.first
  field :action,            type: Enum,           in: self.actions,            default: self.actions.first
  field :detail,            type: Text

  belongs_to :provider
  belongs_to :patient

  before_validation :set_datetimes
  after_initialize :get_datetimes

  default_scope { order(created_at: :desc) }

  attr_accessor :created_at_date, :created_at_time

  private

  def get_datetimes
    self.created_at ||= Time.now

    self.created_at_date ||= self.created_at.to_date.to_s(:frontend_date)
    self.created_at_time ||= "#{'%02d' % self.created_at.to_time.hour}:#{'%02d' % self.created_at.to_time.min}"
  end

  def set_datetimes
    self.created_at = "#{Date.strptime(self.created_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.created_at_time}".to_time
  end
end
