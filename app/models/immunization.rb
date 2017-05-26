class Immunization
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.names
    [:Administered, :Historical, :Refused]
  end

  def self.manufacturers
    [
      :'Acambis', :'Barr Labs Inc.', :'bioCSL', :'Emergent BioSolutions', :'GlaxoSmithKline', :'Massachusetts Biological Labs', :'Medimmune', :'Merck', :'Novartis', :'PaxVax', :'Protein Sciences', :'sanofi', :'Valneva', :'Wyeth / Pfizer'
    ]
  end

  def self.source_of_informations
    [
       :'Administered by another Provider', :'Birth Certification', :'Immunization Registry', :"Parent's Recall", :"Parent's Written Record", :'Patient', :'Public Agency', :'School Record', :'Source Unspecified'
    ]
  end

  def self.reason_refuseds
    [
       :'Immunity', :'Medical Precaution', :'Other', :'Out of Stock', :'Parental Decision', :'Patient Decision', :'Patient Objection', :'Philosophical Objection', :'Religious Exemption', :'Religious Objection', :'Vaccine Efficacy Concerns', :'Vaccine Safety Concerns'
    ]
  end

  def self.units
    [
       :'EL U/0.5 ML' , :'EL U/ML' , :'GM' , :'GM/100 ML' , :'GM/10 ML' , :'GM/200 ML' , :'GM/20 ML' , :'GM/400 ML' , :'GM/500 ML' , :'GM/50 ML' , :'LF-MCG/0.5' , :'LF/O.5 ML' , :'LFU' , :'LFU/0.5 ML' , :'MCG' , :'MCG/0.5 ML' , :'MCG/ML' , :'MCG/STRAIN' , :'MG/0.5 ML' , :'MG/ML' , :'ML' , :'PFU/0.5 ML' , :'UNIT' , :'UNIT/0.5 ML' , :'UNIT/1.2 ML' , :'UNIT/1.3 ML' , :'UNIT/13 ML' , :'UNIT/2.2 ML' , :'UNIT/2 ML' , :'UNIT/ 4.4 ML' , :'UNIT/ML' , :'UNIT/0.65 ML'
    ]
  end

  def self.routes
    [
       :'Apply externally' , :'Buccal' , :'Dental' , :'Endotrachial tube' , :'Epidural' , :'Gastrostomy tub' , :'GU irrigant' , :'Immerse (soak) body part' , :'Inhalation' , :'Intra-arterial' , :'Intrabursal' , :'Intracardiac' , :'Intracervical(uterus)' , :'Intradermal' , :'Intrahepatic artery' , :'Intramuscular' , :'Intranasal' , :'Intraocular' , :'Intraperitoneal' , :'Intrasynovial' , :'Intrathecal' , :'Intrauterine' , :'Intravenous' , :'Mouth/throat' , :'Mucous membrane' , :'Nasal' , :'Nasal prongs' , :'Nasogastric' , :'Nastrachial tube' , :'Ophthalmic' , :'Oral' , :'Other/miscellaneous' , :'Otic' , :'Perfusion' , :'Rebreather mask' , :'Rectal' , :'Soaked dressing' , :'Subcutaneous' , :'Sublingual' , :'Topical' , :'Tracheostomy' , :'Transdermal' , :'Translingual' , :'Urethral' , :'Vaginal' , :'Ventimask'
    ]
  end

  def self.body_sites
    [
       :'Bilateral Ears' , :'Bilateral Eyes' , :'Bilateral Nares' , :'Bladder' , :'Buttock' , :'Chest tube' , :'Left Antecubital Fossa' , :'Left Anterior Chest' , :'Left Arm' , :'Left Buttock' , :'Left Deltoid' , :'Left Ear' , :'Left External Jugular' , :'Left Eye' , :'Left Foot' , :'Left Forearm' , :'Left Gluteus' , :'Left Gluteus Medius' , :'Left Hand' , :'Left Internal Jugular' , :'Left Lower Abdomen' , :'Left Lower Forearm' , :'Left Mid-Forearm' , :'Left Naris' , :'Left Posterior Chest' , :'Left Quadriceps' , :'Left Subclavian' , :'Left Thigh' , :'Left Upper Abdomen' , :'Left Upper Arm' , :'Left Upper Forearm' , :'Left Vastus Lateralis' , :'Left Ventragluteal' , :'Mouth' , :'Nebulized' , :'Perianal' , :'Perineal' , :'Right Antecubital Fossa' , :'Right Anterior Chest' , :'Right Arm' , :'Right Buttock' , :'Right Deltoid' , :'Right Ear' , :'Right External Jugular' , :'Right Eye' , :'Right Foot' , :'Right Forearm' , :'Right Gluteus' , :'Right Gluteus Medius' , :'Right Hand' , :'Right Internal Jugular' , :'Right Lower Abdomen' , :'Right Lower Forearm' , :'Right Mid-Forearm' , :'Right Naris' , :'Right Posterior Chest' , :'Right Quadriceps' , :'Right Subclavian' , :'Right Thigh' , :'Right Upper Abdomen' , :'Right Upper Arm' , :'Right Upper Forearm' , :'Right Vastus Lateralis' , :'Right Ventragluteal'
    ]
  end

  def self.funding_sources
    [
       :'Federal funds', :'Military funds', :'Other source', :'Private funds', :'State funds', :'Tribal funds', :'Unspecified'
    ]
  end

  def self.registry_notifications
    [
       :'No reminder/recall', :'Only recall to provider, no reminder', :'Only reminder to provider, no recall', :'Recall only - any method', :'Recall only - no calls', :'Recall to provider', :'Reminder only - any method', :'Reminder only - no calls', :'Reminder to provider', :'Reminder/recall - any method', :'Reminder/recall - no calls', :'Reminder/recall to provider'
    ]
  end

  def self.vfc_classes
    [
       :'Deprecated [Not VFC eligible-underinsured]', :'Deprecated [VFC eligible-State specific eligibility (e.g. SCHIP plan)]', :'Local-specific eligibility', :'Not VFC eligible', :'VFC eligible - American Indian/Alaskan Native', :'VFC eligible - Federally Qualified Health Center Patient (under-insured)', :'VFC eligible - Medicaid/Medicaid Managed Care', :'VFC eligible - Uninsured'
    ]
  end

  field :name,                      type: Enum,         in: self.names,                  default: self.names.first
  field :administered_at,           type: Time
  field :refused_at,                type: Time
  field :source_of_information,     type: Enum,         in: self.source_of_informations, default: self.source_of_informations.first
  field :reason_refused,            type: Enum,         in: self.reason_refuseds,        default: self.reason_refuseds.first
  field :manufacturer,              type: Enum,         in: self.manufacturers,          default: self.manufacturers.first
  field :lot,                       type: String
  field :quantity,                  type: String
  field :dose,                      type: String
  field :unit,                      type: Enum,         in: self.units,                  default: self.units.first
  field :expiration_at,             type: Time
  field :route,                     type: Enum,         in: self.routes,                 default: self.routes.first
  field :body_site,                 type: Enum,         in: self.body_sites,             default: self.body_sites.first
  field :funding_source,            type: Enum,         in: self.funding_sources,        default: self.funding_sources.first
  field :registry_notification,     type: Enum,         in: self.registry_notifications, default: self.registry_notifications.first
  field :vfc_class,                 type: Enum,         in: self.vfc_classes,            default: self.vfc_classes.first
  field :comments,                  type: Text

  belongs_to :patient
  belongs_to :vaccine
  belongs_to :administered_by,       foreign_key: :administered_by_id,        class_name: :Provider
  belongs_to :ordered_by,            foreign_key: :ordered_by_id,             class_name: :Provider
  belongs_to :administered_facility, foreign_key: :administered_facility_id,  class_name: :Location
  belongs_to :facility,              foreign_key: :facility_id,               class_name: :Location

  before_validation :set_datetimes
  after_initialize :get_datetimes

  attr_accessor :administered_at_date, :administered_at_time
  attr_accessor :refused_at_date, :refused_at_time
  attr_accessor :expiration_at_date, :expiration_at_time

  def to_s
    "#{administered_at.to_time.strftime("%d/%m/%Y %I:%M %p")}"
  end

  def to_label
    "#{name}, #{manufacturer}, #{source_of_information}, #{lot}, EXPIRES: #{expiration_at.try(:strftime, Date::DATE_FORMATS[:dosespot])}"
  end

  private

  def get_datetimes
    self.administered_at ||= Time.now
    self.refused_at      ||= Time.now
    self.expiration_at   ||= Time.now

    self.administered_at_date ||= self.administered_at.to_date.to_s(:frontend_date)
    self.administered_at_time ||= "#{'%02d' % self.administered_at.to_time.hour}:#{'%02d' % self.administered_at.to_time.min}"

    self.refused_at_date ||= self.refused_at.to_date.to_s(:frontend_date)
    self.refused_at_time ||= "#{'%02d' % self.refused_at.to_time.hour}:#{'%02d' % self.refused_at.to_time.min}"

    self.expiration_at_date ||= self.expiration_at.to_date.to_s(:frontend_date)
    self.expiration_at_time ||= "#{'%02d' % self.expiration_at.to_time.hour}:#{'%02d' % self.expiration_at.to_time.min}"
  end

  def set_datetimes
    self.administered_at = "#{Date.strptime(self.administered_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.administered_at_time}".to_time
    self.refused_at      = "#{Date.strptime(self.refused_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.refused_at_time}".to_time
    self.expiration_at   = "#{Date.strptime(self.expiration_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.expiration_at_time}".to_time
  end
end