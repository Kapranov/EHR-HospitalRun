FactoryGirl.define do
  factory :procedure do
    association       :encounter
    tooth_table_id    { nil }
    procedure_code_id { ProcedureCode.sample.try(:id) }
    date_of_service   { Time.now }
    status            { Procedure.statuses.sample }
  end
end
