require_relative '../support/helpers/faker_helpers'

FactoryGirl.define do
  factory :image do
    image { FakerHelpers.sample_image }
  end
end
