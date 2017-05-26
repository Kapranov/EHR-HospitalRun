class DiagnosisCode
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  extend  Searchable

  field  :code,             type: String
  field  :description,      type: String

  # has_many :diagnoses

  self_search [:code, :description], :diagnosis_codes
end
