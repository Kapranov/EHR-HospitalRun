FactoryGirl.define do
  factory :procedure_recommended do
    association    :encounter
    procedure_code { ProcedureCode.limit(10).sample.try(:id) }
  end
end
