class NextKin
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.relations
    [:Parent, :Child, :Wife]
  end

  field :first_name,                  type: String
  field :middle_name,                 type: String
  field :last_name,                   type: String
  field :relation,                    type: Enum,     in: self.relations,  default: self.relations.first
  field :mobile_phone,                type: String
  field :email,                       type: String
  field :street_address,              type: String
  field :city,                        type: String
  field :state,                       type: String
  field :zip,                         type: String

  belongs_to :patient

  attr_accessor :mobile_phone_code, :mobile_phone_tel

  before_validation :set_phones
  before_validation :phony_normalize
  after_initialize :get_phones

  private

  def get_phones
    if self.mobile_phone.present?
      self.mobile_phone_code = self.mobile_phone[2..4]
      self.mobile_phone_tel = self.mobile_phone[4..self.mobile_phone.size-1]
    end
  end

  def set_phones
    self.mobile_phone = [self.mobile_phone_code, self.mobile_phone_tel].join
  end

  def phony_normalize
    self.mobile_phone = PhonyRails.normalize_number(mobile_phone,  default_country_code: 'US')
  end
end
