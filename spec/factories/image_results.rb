FactoryGirl.define do
  factory :image_result do
    association           :patient
    schedule_at         { Time.now }
    exam                { Faker::Lorem.sentence }
    requested_by        { Faker::Lorem.sentence }
    history             { Faker::Lorem.sentence }
    radiophamaceutical  { Faker::Lorem.sentence }
    technique           { Faker::Lorem.sentence }
    comparison          { Faker::Lorem.sentence }
    findings            { Faker::Lorem.sentence }
    impression          { Faker::Lorem.sentence }
    images              { [] }
  end
end
