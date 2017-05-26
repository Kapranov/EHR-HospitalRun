FactoryGirl.define do
  factory :diagnosis do
    association       :patient
    snomed_id         { Snomed.limit(10).sample.try(:id) }
    start_date        { Time.now - 1.hour }
    stop_date         { Time.now + 1.hour }
    acute             { true }
    terminal          { true }
    note              { Faker::Hipster.sentence }
    referral          { false }
  end
end
