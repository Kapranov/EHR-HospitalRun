FactoryGirl.define do
  factory :education_material do
    name        { Faker::Name.first_name }
    code_system { EducationMaterial.fields[:code_system][:default] }
    code_id     { Faker::Code.ean }
    note        { Faker::Lorem.sentence }

    factory :invalid_education_material do
      code_system { :'Unknown status' }
    end
  end
end
