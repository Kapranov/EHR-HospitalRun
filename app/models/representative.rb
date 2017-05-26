class Representative
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :first_name,       type: String
  field :last_name,        type: String
  field :primary_phone,    type: String
  field :active,           type: Boolean,    default: false

  belongs_to :patient
  belongs_to :user

  before_validation :set_phones
  before_validation :phony_normalize
  after_initialize :get_phones

  attr_accessor :primary_phone_code, :primary_phone_tel

  private

  def get_phones
    if self.primary_phone.present?
      self.primary_phone_code = self.primary_phone[2..4]
      self.primary_phone_tel = self.primary_phone[4..self.primary_phone.size-1]
    end
  end

  def set_phones
    self.primary_phone = [self.primary_phone_code, self.primary_phone_tel].join
  end

  def phony_normalize
    self.primary_phone = PhonyRails.normalize_number(primary_phone, default_country_code: 'US')
  end
end
