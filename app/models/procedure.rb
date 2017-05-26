class Procedure
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.statuses
    [
        :'Other Provider',
        :'Existing',
        :'Completed',
        :'Treatment planned'
    ]
  end

  field :date_of_service, type: Time
  field :status,          type: Enum,   in: self.statuses,   default: self.statuses.first

  has_one    :surface
  has_one    :pit
  has_one    :cusp
  belongs_to :procedure_code
  belongs_to :tooth_table
  belongs_to :patient
  belongs_to :encounter

  before_validation :set_datetimes
  after_initialize :get_datetimes
  after_create :send_create_sms
  after_update :send_update_sms

  attr_accessor :date_of_service_date, :date_of_service_time

  def short_status
    status.present? ? status.to_s.split(' ').map{ |w| w[0] }.join().upcase : ''
  end

  def to_label
    procedure_code.try(:to_label) || ''
  end

  private

  def get_datetimes
    self.date_of_service ||= Time.now

    self.date_of_service_date ||= self.date_of_service.to_date.to_s(:frontend_date)
    self.date_of_service_time ||= "#{'%02d' % self.date_of_service.to_time.hour}:#{'%02d' % self.date_of_service.to_time.min}"
  end

  def set_datetimes
    self.date_of_service = "#{Date.strptime(self.date_of_service_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.date_of_service_time}".to_time
  end

  def send_create_sms
    body = "New procedure for patient #{encounter.try(:patient).try(:full_name)} was created"
    TextMessage.create(to: encounter.try(:provider).try(:primary_phone), body: body)
  end

  def send_update_sms
    body = "Procedure for patient #{encounter.try(:patient).try(:full_name)} was updated"
    TextMessage.create(to: encounter.try(:provider).try(:primary_phone), body: body)
  end
end
