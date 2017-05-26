module Provider::SmsNotifiable
  def self.included(base)
    base.class_eval do
      after_create :send_create_sms,  if: proc { primary_phone.present? }
      after_update :send_update_sms,  if: proc { primary_phone.present? }
    end
  end

  def send_create_sms
    body = "New provider #{full_name} was created"
    TextMessage.create(to: primary_phone, body: body)
  end

  def send_update_sms
    body = "Provider #{full_name} was updated"
    TextMessage.create(to: primary_phone, body: body)
  end
end