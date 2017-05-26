FactoryGirl.define do
  factory :lab_order do
    association          :patient
    order_type         { LabOrder.fields[:order_type][:default] }
    lab_name           { LabOrder.fields[:lab_name][:default] }
    status             { LabOrder.fields[:status][:default] }
    ordering_physician { nil }
    ordering_facility  { LabOrder.fields[:ordering_facility][:default] }
    lab_status         { LabOrder.fields[:lab_status][:default] }
    schedule_at        { Time.now }
    received_at        { Time.now }
    notes              { nil }
  end
end
