FactoryGirl.define do
  factory :surface do
    association :procedure
    mesial      { true }
    incisal     { true }
    distal      { true }
    lingual     { true }
    facial      { true }
    class_five  { true }
  end
end
