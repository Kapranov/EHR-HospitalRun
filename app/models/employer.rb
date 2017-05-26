class Employer
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :name,           type: String
  field :phone,          type: String
  field :street_address, type: String
  field :city,           type: String
  field :state,          type: String
  field :zip,            type: String

  belongs_to :insurance

  attr_accessor :phone_code, :phone_tel

  before_validation :set_phones
  before_validation :phony_normalize
  after_initialize :get_phones

  private

  def get_phones
    if self.phone.present?
      self.phone_code = self.phone[2..4]
      self.phone_tel = self.phone[4..self.phone.size-1]
    end
  end

  def set_phones
    self.phone = [self.phone_code, self.phone_tel].join
  end

  def phony_normalize
    self.phone = PhonyRails.normalize_number(phone,  default_country_code: 'US')
  end
end