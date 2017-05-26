FactoryGirl.define do
  factory :lab do
    association :patient
    association :provider
    order_type  { Lab.fields[:order_type][:default] }
    lab_name    { Lab.fields[:lab_name][:default] }
    status      { Lab.fields[:status][:default] }
    ordering_physician { Lab.fields[:ordering_physician][:default] }
    ordering_facility  { Lab.fields[:ordering_facility][:default] }
    lab_status  { Lab.fields[:lab_status][:default] }
    schedule_at { Time.now }
    received_at { Time.now }
    notes       { Faker::Lorem.sentence }
  end
end
