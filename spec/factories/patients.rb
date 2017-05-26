require_relative '../support/helpers/faker_helpers'

FactoryGirl.define do
  factory :patient do
    association    :user, role: :Patient
    association    :provider
    first_name     { Faker::Name.first_name }
    middle_name    { Faker::Name.first_name }
    last_name      { Faker::Name.last_name  }
    birth          { Time.now - 10.year }
    street_address '712 Main Street'
    mobile_phone   '+17817215566'
    primary_phone  '+17813869851'
    social_number  { (1..9).map{"123456789".chars.to_a.sample}.join }
    city           'Holtsville'
    state          'New York'
    zip            '50112'
    provider_id    nil
    active         true
    profile_image  { FakerHelpers.sample_image }
  end
end
