class Claim
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :first_name,        type: String
  field :middle_name,       type: String
  field :last_name,         type: String
  field :street_address1,   type: String
  field :street_address2,   type: String
  field :phone,             type: String
  field :fax,               type: String
  field :ext1,              type: String
  field :ext2,              type: String
  field :city,              type: String
  field :state,             type: String
  field :zip,               type: String
  field :notes,             type: Text

  belongs_to :payer

  attr_accessor :phone_code, :phone_tel
  attr_accessor :fax_code, :fax_tel

  before_validation :set_phones
  before_validation :phony_normalize
  after_initialize :get_phones

  private

  def get_phones
    if self.phone.present?
      self.phone_code = self.phone[2..4]
      self.phone_tel = self.phone[4..self.phone.size-1]
    end
    if self.fax.present?
      self.fax_code = self.fax[2..4]
      self.fax_tel = self.fax[4..self.fax.size-1]
    end
  end

  def set_phones
    self.phone = [self.phone_code, self.phone_tel].join
    self.fax = [self.fax_code, self.fax_tel].join
  end

  def phony_normalize
    self.phone = PhonyRails.normalize_number(phone, default_country_code: 'US')
    self.fax   = PhonyRails.normalize_number(fax,   default_country_code: 'US')
  end
end