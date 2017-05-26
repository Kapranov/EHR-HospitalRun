require_relative '../support/helpers/faker_helpers'

FactoryGirl.define do
  factory :attachment do
    association       :amendment
    file_name         { FakerHelpers.sample_image }

    # factory :invalid_attachment do
    # can't be invalid, oops)
    # end
  end
end