FactoryGirl.define do
  factory :representative do
    association     :user, role: :Representative
    association     :patient
    first_name      { Faker::Name.first_name }
    last_name       { Faker::Name.last_name }
    primary_phone   '2012012112'
    active          true
  end
end
