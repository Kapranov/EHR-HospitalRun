class FamilyHealthHistory
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  extend Containerable

  def self.relationships
    [ :'Parent-Mother',  :'Parent-Father',   :Parent,
      :'Sibling-Sister', :'Sibling-Brother', :Sibling,
      :'Child-Daughter', :'Child-Son',       :Child,
      :'Grandparent-Grandmother', :'Grandparent-Grandfather', :Grandparent, :'Great Grandparent',
      :Uncle, :Aunt, :Cousin, :Other, :Unknown]
  end

  field :first_name,         type: String
  field :last_name,          type: String
  field :relationship,       type: Enum,         in: self.relationships
  field :birth_at,           type: Time
  field :age,                type: Integer
  field :deceased,           type: Boolean
  field_array :dx,      cleanable: true
  field :notes,              type: Text

  belongs_to :past_medical_history

  attr_accessor :birth_at_date, :birth_at_time

  before_validation :set_datetimes
  after_initialize :get_datetimes

  def to_label
    "#{first_name} #{last_name}, #{relationship}"
  end

  private

  def get_datetimes
    self.birth_at ||= Time.now

    self.birth_at_date ||= self.birth_at.to_date.to_s(:frontend_date)
    self.birth_at_time ||= "#{'%02d' % self.birth_at.to_time.hour}:#{'%02d' % self.birth_at.to_time.min}"
  end

  def set_datetimes
    self.birth_at = "#{Date.strptime(self.birth_at_date, Date::DATE_FORMATS[:frontend_date]).to_s(:db)} #{self.birth_at_time}".to_time
  end
end
