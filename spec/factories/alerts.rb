FactoryGirl.define do
  factory :alert do
    association    :provider
    name           { Faker::Name.first_name }
    description    { Faker::Lorem.sentence }
    resolution     { Faker::Lorem.sentence }
    bibliography   { Faker::Lorem.sentence }
    developer      { Faker::Lorem.sentence }
    funding_source { Faker::Lorem.sentence }
    release_date   { Time.now }
    rule           { Alert.rules.first }

    factory :invalid_alert do
      rule         { :'Unknown rule' }
    end
  end
end
