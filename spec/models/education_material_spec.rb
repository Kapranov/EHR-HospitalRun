describe EducationMaterial do
  clean_users

  it { should validate_inclusion_of(:code_system).in_array(EducationMaterial.code_systems) }
end
