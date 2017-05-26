FactoryGirl.define do
  factory :procedure_completed do
    association    :encounter
    procedure_code { ProcedureCode.limit(10).sample.try(:id) }
  end
end
