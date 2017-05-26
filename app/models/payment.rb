class Payment
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.cards
    [:'visa', :'master card', :'discover', :'american express']
  end

  FEE = 199 # in $

  field :annual,         type: Boolean,                   default: nil
  field :card,           type: Enum,    in: self.cards,   default: self.cards.first
  field :card_num,       type: String
  field :cvc,            type: Integer
  field :expiration_at,  type: Time
  field :token,          type: String
  field :card_name,      type: String
  field :stripe_id,      type: String
  field :subscribed,     type: Boolean, default: false # subscribed for monthly or yearly pays
  field :fee_paid,       type: Boolean, default: false

  belongs_to :provider

  before_validation :set_expiration
  after_initialize :get_expiration

  before_destroy :delete_stripe_account
  after_create   :set_stripe_id

  attr_accessor :expiration_at_month, :expiration_at_year

  def self.plans
    {
        annual:  { amount: 2975, id: 'Annual'  },
        monthly: { amount: 299,  id: 'Monthly' }
    }
  end

  def self.plan_by(plan_type)
    "#{plans[plan_type][:id]} #{plans[plan_type][:amount]}$"
  end

  def self.fee
    FEE
  end

  def plan_id
    (annual ? Payment.plans[:annual] : Payment.plans[:monthly])[:id]
  end

  def expiration_at_to_str
    expiration_at.present? ? "#{expiration_at.month}/#{expiration_at.year - 2000}" : ''
  end

  def customer
    Stripe::Customer.retrieve(stripe_id)
  end

  def set_source
    # Stripe::Token.create(card: { number: "378282246310005", exp_month: 11, exp_year: 2016, cvc: 322})
    if token.blank?
      token = Stripe::Token.create(card: { number: card_num,
                                           exp_month: expiration_at.month,
                                           exp_year: expiration_at.year,
                                           cvc: cvc }).id

      customer.sources.create(source: token)
      update(token: token)
    end
  end

  def subscribe
    # Stripe::Customer.create(source: "tok_185cAUINpK6RUKju4fNMIS1x", :plan => "Annual", :email => "aa@aa.aa")
    set_source
    customer.subscriptions.create({ plan: plan_id })
    update(subscribed: true)
  end

  def pay_fee
    Stripe::Charge.create(
        amount: FEE * 100, # amount in cents, again
        currency: 'usd',
        customer: stripe_id,
        description: 'Fee'
    )
    update(fee_paid: true)
  end

  def pay
    begin
      subscribe unless subscribed
      pay_fee   unless fee_paid
      true
    rescue => e
      errors.add(:base, :card_error, message: e.message)
      false
    end
  end

  def set_stripe_id
    update(stripe_id: Stripe::Customer.create(email: provider.user.email).id) if provider.user.present?
  end

  def plan_name
    annual.nil? ? 'Non Paid' : self.class.plan_by(annual ? :annual : :monthly)
  end

  protected

  def get_expiration
    self.expiration_at ||= Time.now

    if self.expiration_at.present?
      self.expiration_at_month = self.expiration_at.strftime('%m')
      self.expiration_at_year = self.expiration_at.strftime('%y')
    end
  end

  def set_expiration
    self.expiration_at = self.expiration_at.change({ month: expiration_at_month, year: expiration_at.strftime('%C') + expiration_at_year })
  end

  def delete_stripe_account
    customer.delete if stripe_id.present?
  end
end