class TextMessage
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field  :to,              type: String
  field  :from,            type: String
  field  :body,            type: Text

  belongs_to :provider
  belongs_to :patient

  before_create :send_message, if: Proc.new { Rails.env == 'production' }

  def send_message
    from = "+#{Rails.application.secrets.twilio_phone_number}"
    client = Twilio::REST::Client.new
    begin
      client.messages.create(from: from, to: to, body: body)
    rescue Twilio::REST::RequestError => e
      raise TwillioError.new, e.message
    rescue => e
      raise TwillioError.new, 'Twillio is currently unavailable'
    end
  end

  def self.valid?(phone_number)
    return false if phone_number.blank?
    begin
      Twilio::REST::LookupsClient.new.phone_numbers.get(phone_number).phone_number # if invalid, throws an exception. If valid, no problems.
      true
    rescue => e
      e.code == 20404 ? false : raise(e)
    end
  end

  class TwillioError < StandardError
  end
end
