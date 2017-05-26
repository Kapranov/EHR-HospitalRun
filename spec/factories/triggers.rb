FactoryGirl.define do
  factory :trigger do
    association    :alert
    category       { Trigger.categories.first }
    system         { Trigger.systems.first }
    code           { Faker::Code.ean }
    description    { Faker::Lorem.sentence }
  end
end
