FactoryGirl.define do
  factory :amendment do
    association       :patient
    requested_at      { Time.now }
    accepted_at       { Time.now }
    appended_at       { Time.now }
    status            { Amendment.statuses.first }
    source            { Amendment.sources.first }
    description       { Faker::Lorem.sentence }
    note              { Faker::Lorem.sentence }

    factory :invalid_amendment do
      status          { :'Unknown status' }
    end
  end
end
