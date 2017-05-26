class Allergy
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  include Allergy::Reconciliationable

  def self.allergen_types
    [:Drug, :Food, :Environment]
  end

  def self.severity_levels
    [:'Very Mild', :Mild, :Moderate, :Severe]
  end

  def self.onset_ats
    [:Childhood, :Adulthood, :Unkhown]
  end

  field :allergen_type,       type: Enum,     in: self.allergen_types,    default: self.allergen_types.first
  field :severity_level,      type: Enum,     in: self.severity_levels,   default: self.severity_levels.first
  field :onset_at,            type: Enum,     in: self.onset_ats,         default: self.onset_ats.first
  field :start_date,          type: Time
  field :active,              type: Boolean
  field :note,                type: Text
  field :dosespot_allergy_id, type: String
  field :referral,            type: Boolean,     default: false

  belongs_to :patient

  default_scope    { order(:created_at) }
  scope :drugs, -> { where(allergen_type: :Drug) }
  scope :foods, -> { where(allergen_type: :Food) }
  scope :envs,  -> { where(allergen_type: :Environment) }

  before_validation :set_datetimes
  after_initialize  :get_datetimes

  attr_accessor :start_date_date, :start_date_time

  def to_label
    "#{allergen_type} REACTIONS: #{active}, SEVERITY: #{severity_level}, ONSET: #{onset_at.try(:strftime, Date::DATE_FORMATS[:dosespot])}, START DATE: #{start_date.try(:strftime, Date::DATE_FORMATS[:dosespot])}"
  end

  private

  def get_datetimes
    self.start_date ||= Time.now

    self.start_date_date ||= self.start_date.to_date.to_s(:frontend_date)
    self.start_date_time ||= "#{'%02d' % self.start_date.to_time.hour}:#{'%02d' % self.start_date.to_time.min}"
  end

  def set_datetimes
    self.start_date = "#{Date.strptime(self.start_date_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.start_date_time}".to_time
  end
end
