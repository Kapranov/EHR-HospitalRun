class PastMedicalHistory
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :major_events,           type: Text
  field :ongoing_problems,       type: Text
  field :preventitive_care,      type: Text
  field :nutrition_history,      type: Text

  has_many   :family_health_histories
  belongs_to :patient
end
