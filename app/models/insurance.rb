class Insurance
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.relations
    [
        :'Associate',
        :'Brother',
        :'Care giver',
        :'Child',
        :'Emergency contact',
        :'Employee',
        :'Employer',
        :'Extended family',
        :'Father',
        :'Foster child',
        :'Friend',
        :'Grandchild',
        :'Grandparent',
        :'Guardian',
        :'Handicapped dependent',
        :'Life partner',
        :'Manager',
        :'Mother',
        :'Natural child',
        :'None',
        :'Other',
        :'Other adult',
        :'Owner',
        :'Parent',
        :'Self',
        :'Sibling',
        :'Sister',
        :'Spouse',
        :'Stepchild',
        :'Trainer',
        :'Unknown',
        :'Ward of court'
    ]
  end

  def self.copay_types
    [:'$', :'%']
  end

  field :worker_compensation, type: Boolean, default: false
  field :insurance_number,    type: String
  field :relation,            type: Enum,    in: self.relations,   default: self.relations.first
  field :effective_from,      type: Time
  field :effective_to,        type: Time
  field :copay_type,          type: Enum,    in: self.copay_types, default: self.copay_types.first
  field :copay_amount,        type: Float
  field :claim,               type: Integer
  field :note,                type: Text
  field :active,              type: Boolean

  has_one :employer,   dependent: :destroy
  has_one :subscriber, dependent: :destroy
  belongs_to :patient
  belongs_to :provider
  belongs_to :payer

  before_validation :set_datetimes
  after_initialize :get_datetimes

  attr_accessor :effective_from_date, :effective_from_time
  attr_accessor :effective_to_date, :effective_to_time

  private

  def get_datetimes
    self.effective_from ||= Time.now
    self.effective_to   ||= Time.now

    self.effective_from_date ||= self.effective_from.to_date.to_s(:frontend_date)
    self.effective_from_time ||= "#{'%02d' % self.effective_from.to_time.hour}:#{'%02d' % self.effective_from.to_time.min}"

    self.effective_to_date ||= self.effective_to.to_date.to_s(:frontend_date)
    self.effective_to_time ||= "#{'%02d' % self.effective_to.to_time.hour}:#{'%02d' % self.effective_to.to_time.min}"
  end

  def set_datetimes
    self.effective_from = "#{Date.strptime(self.effective_from_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.effective_from_time}".to_time
    self.effective_to   = "#{Date.strptime(self.effective_to_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.effective_to_time}".to_time
  end
end