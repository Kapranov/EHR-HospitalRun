class PaymentAgreementSign
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :full_name,         type: String
  field :agreement,         type: Boolean, default: false

  belongs_to :provider

  def agreeded?
    agreement && full_name.downcase == provider.full_name.downcase
  end
end
