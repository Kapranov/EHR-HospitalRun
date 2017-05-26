class Dx
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field  :onset_at,       type: Time

  belongs_to :snomed

  def to_label
    "#{snomed.try(:defaultTerm)}, onset: #{onset_at.try(:strftime, Date::DATE_FORMATS[:frontend_date])}"
  end
end
