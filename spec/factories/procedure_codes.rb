FactoryGirl.define do
  factory :procedure_code do
    code "D0#{(100..999).to_a.sample}"
  end
end
