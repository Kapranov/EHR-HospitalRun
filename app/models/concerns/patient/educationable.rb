module Patient::Educationable
  def add_education_material(material_id)
    unless education_material_exist?(material_id)
      PatientEducationMaterial.create(patient_id: id, education_material_id: material_id)
    end
  end

  def remove_education_material(material_id)
    if education_material_exist?(material_id)
      PatientEducationMaterial.where(patient_id: id, education_material_id: material_id).first.destroy
    end
  end

  def education_material_exist?(material_id)
    material_id.present? && PatientEducationMaterial.where(patient_id: id, education_material_id: material_id).any?
  end
end