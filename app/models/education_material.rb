class EducationMaterial
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  include AttachmentCollectionable

  def self.code_systems
    [:ICD10, :SNOMED, :CDT, :LOINC, :NDC, :Medline]
  end

  field :name,          type: String
  field :code_system,   type: Enum,        in: self.code_systems,   default: :SNOMED
  field :code_id,       type: String
  field :note,          type: String

  has_many   :patient_education_materials
  has_many   :patients,                      through:   :patient_education_materials
  belongs_to :provider

  def to_label
    "#{name} (#{code_id})"
  end
end
