class SmokingStatus
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.statuses
    statuses_with_codes.keys
  end

  def self.statuses_with_codes
    {
        :'Never Smoked Ever' => '266919005',
        :'Current Every Day Smoker' => '449868002',
        :'Unknown if Ever Smoked' => '266927001',
        :'Current Some Day Smoker' => '428041000124106',
        :'Former Smoker' => '8517006',
        :'Heavy Tobacco Smoker' => '428071000124103',
        :'Smoker, Current Status Unknown' => '77176002',
        :'Light Tobacco Smoker' => '428061000124105'
    }
  end

  field :status,         type: Enum, in: self.statuses, default: self.statuses.first
  field :effective_from, type: Time

  belongs_to :patient

  before_validation :set_datetimes
  after_initialize :get_datetimes

  attr_accessor :effective_from_date, :effective_from_time

  def to_label
    status.to_s
  end

  private

  def get_datetimes
    self.effective_from ||= Time.now

    self.effective_from_date ||= self.effective_from.to_date.to_s(:frontend_date)
    self.effective_from_time ||= "#{'%02d' % self.effective_from.to_time.hour}:#{'%02d' % self.effective_from.to_time.min}"
  end

  def set_datetimes
    self.effective_from = "#{Date.strptime(self.effective_from_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.effective_from_time}".to_time
  end
end
