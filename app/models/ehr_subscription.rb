class EhrSubscription
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.rates
    { doctor: 249, staff: 4.99 }
  end

  field :paid,                 type: Boolean,   default: false
  field :doctors,              type: Integer
  field :additional_staff,     type: Boolean,   default: false
  field :staff,                type: Integer

  field :billing,              type: Boolean,   default: true
  field :billing_first_name,   type: String
  field :billing_last_name,    type: String
  field :billing_email,        type: String
  field :billing_phone,        type: String

  field :technical,            type: Boolean,   default: true
  field :technical_first_name, type: String
  field :technical_last_name,  type: String
  field :technical_email,      type: String
  field :technical_phone,      type: String

  belongs_to :payment
  belongs_to :provider

  attr_accessor :billing_phone_code, :billing_phone_tel
  attr_accessor :technical_phone_code, :technical_phone_tel

  before_validation :set_phones, :phony_normalize
  after_initialize :get_phones

  after_create :create_payment

  def price_for_doctors
    (doctors * (payment.annual ? (Payment.plans[:annual])[:amount] : EhrSubscription.rates[:doctor])).round(2)
  end

  def price_for_staff
    additional_staff ? (staff * EhrSubscription.rates[:staff]).round(2) : 0
  end

  def fee
    payment.fee_paid ? 0 : Payment.fee
  end

  def total
    price_for_doctors + price_for_staff + fee
  end

  def get_count
    count = 0
    if !payment.subscribed
      count += 1 if doctors.present? && doctors > 0
      count += 1 if additional_staff
    end
    return count
  end

  private

  def get_phones
    if self.billing_phone.present?
      self.billing_phone_code = self.billing_phone[2..4]
      self.billing_phone_tel = self.billing_phone[4..self.billing_phone.size-1]
    end
    if self.technical_phone.present?
      self.technical_phone_code = self.technical_phone[2..4]
      self.technical_phone_tel = self.technical_phone[4..self.technical_phone.size-1]
    end
  end

  def set_phones
    self.billing_phone = [self.billing_phone_code, self.billing_phone_tel].join
    self.technical_phone = [self.technical_phone_code, self.technical_phone_tel].join
  end

  def phony_normalize
    self.billing_phone = PhonyRails.normalize_number(billing_phone, default_country_code: 'US')
    self.technical_phone = PhonyRails.normalize_number(technical_phone, default_country_code: 'US')
  end

  def create_payment
    update(payment_id: Payment.create(provider_id: provider.id).id)
  end
end
