require_relative '../support/helpers/faker_helpers'

FactoryGirl.define do
  factory :education_attachment do
    association       :education_material
    file_name         { FakerHelpers.sample_image }

    # factory :invalid_education_attachment do
    # can't be invalid, oops)
    # end
  end
end