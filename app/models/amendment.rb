class Amendment
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.statuses
    [:Requested, :Accepted, :Denied]
  end

  def self.sources
    [:Practice, :Patient, :Organization, :Other]
  end

  field :requested_at,      type: Time
  field :accepted_at,       type: Time
  field :appended_at,       type: Time
  field :status,            type: Enum,     in: self.statuses,    default: self.statuses.first
  field :source,            type: Enum,     in: self.sources,     default: self.sources.first
  field :description,       type: String
  field :note,              type: Text

  has_many   :attachments,  dependent: :destroy
  belongs_to :patient

  def scanned
    attachments.any?
  end

  attr_accessor :requested_at_date, :requested_at_time
  attr_accessor :accepted_at_date, :accepted_at_time
  attr_accessor :appended_at_date, :appended_at_time

  before_validation :set_datetimes
  after_initialize  :get_datetimes

  private

  def get_datetimes
    self.requested_at ||= Time.now
    self.accepted_at  ||= Time.now
    self.appended_at  ||= Time.now

    self.requested_at_date ||= self.requested_at.to_date.to_s(:frontend_date)
    self.requested_at_time ||= "#{'%02d' % self.requested_at.to_time.hour}:#{'%02d' % self.requested_at.to_time.min}"

    self.accepted_at_date  ||= self.accepted_at.to_date.to_s(:frontend_date)
    self.accepted_at_time  ||= "#{'%02d' % self.accepted_at.to_time.hour}:#{'%02d' % self.accepted_at.to_time.min}"

    self.appended_at_date   ||= self.appended_at.to_date.to_s(:frontend_date)
    self.appended_at_time   ||= "#{'%02d' % self.appended_at.to_time.hour}:#{'%02d' % self.appended_at.to_time.min}"
  end

  def set_datetimes
    self.requested_at = "#{Date.strptime(self.requested_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.requested_at_time}".to_time if self.requested_at_date.present?
    self.accepted_at = "#{Date.strptime(self.accepted_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.accepted_at_time}".to_time if self.accepted_at_date.present?
    self.appended_at = "#{Date.strptime(self.appended_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.appended_at_time}".to_time if self.appended_at_date.present?
  end
end
