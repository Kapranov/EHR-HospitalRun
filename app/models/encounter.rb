class Encounter
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :serviced_at,       type: Time
  field :notes,             type: Text
  field :med_completed,     type: Boolean
  field :patient_education, type: Boolean
  field :clinical_summary,  type: Boolean
  field :to_provider_id,    type: String
  field :from_provider_id,  type: String

  has_many   :procedures
  has_many   :procedure_completeds,   dependent: :destroy
  has_many   :procedure_recommendeds, dependent: :destroy
  has_one    :vital, dependent: :destroy
  belongs_to :provider
  belongs_to :patient
  belongs_to :referred_to,   foreign_key: :to_provider_id,   class_name: 'Provider'
  belongs_to :referred_from, foreign_key: :from_provider_id, class_name: 'Provider'

  after_create :send_create_sms
  after_update :send_update_sms

  before_validation :set_datetimes
  after_initialize :get_datetimes

  attr_accessor :serviced_at_date, :serviced_at_time

  def to_label
    "#{serviced_at.try(:strftime, Date::DATE_FORMATS[:dosespot])}, #{procedures.try(:first).try(:tooth_table).try(:tooth_num)}, #{notes}, #{created_at.try(:strftime, Date::DATE_FORMATS[:dosespot])}, REPORTED: #{med_completed ? 'Y' : 'N'}"
  end

  private

  def get_datetimes
    self.serviced_at ||= Time.now

    self.serviced_at_date ||= self.serviced_at.to_date.to_s(:frontend_date)
    self.serviced_at_time ||= "#{'%02d' % self.serviced_at.to_time.hour}:#{'%02d' % self.serviced_at.to_time.min}"
  end

  def set_datetimes
    self.serviced_at = "#{Date.strptime(self.serviced_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.serviced_at_time}".to_time
  end

  def send_create_sms
    body = "New encounter for patient #{patient.try(:full_name)} was created"
    TextMessage.create(to: provider.try(:primary_phone), body: body)
  end

  def send_update_sms
    body = "Encounter for patient #{patient.try(:full_name)} was updated"
    TextMessage.create(to: provider.try(:primary_phone), body: body)
  end
end
