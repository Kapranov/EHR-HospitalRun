class PatientEducationMaterial
  include NoBrainer::Document

  belongs_to :patient
  belongs_to :education_material
end