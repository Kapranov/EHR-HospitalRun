require_relative '../support/helpers/faker_helpers'

FactoryGirl.define do
  factory :provider do
    association              :user, role: :Provider
    practice_role            :Provider
    first_name               { Faker::Name.first_name }
    last_name                { Faker::Name.last_name  }
    street_address           { Faker::Address.street_name }
    suit_apt_number          { Faker::Address.building_number }
    city                     'Holtsville'
    state                    'New York'
    zip                      '5500'
    dosespot_user_id         1052
    primary_phone_code       '201'
    primary_phone_tel        '2012112'
    primary_phone            '2012012112'
    mobile_phone_code        '201'
    mobile_phone_tel         '2011221'
    mobile_phone             '2012011221'
    active                   { Provider.fields[:active][:default] }
    trial                    { Provider.fields[:trial][:default] }
    accepting_patient        { Provider.fields[:accepting_patient][:default] }
    enable_online_booking    { Provider.fields[:enable_online_booking][:default] }
    notify                   { Provider.fields[:notify][:default] }
    alt_email                { Faker::Internet.email }
    profile_image            { FakerHelpers.sample_image }

    factory :invalid_provider do
      primary_phone '+11111111111'
    end

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

    trait :paid do
      trial nil
    end

    trait :trial do
      trial 30
    end

    factory :active_and_trial_provider,   traits: [:active,   :trial]
    factory :inactive_and_trial_provider, traits: [:inactive, :trial]
    factory :active_and_paid_provider,    traits: [:active,   :paid]
    factory :inactive_and_paid_provider,  traits: [:inactive, :paid]

    factory :provider_with_blank_phones do
      primary_phone_code       nil
      primary_phone_tel        nil
      primary_phone            nil
      mobile_phone_code        nil
      mobile_phone_tel         nil
      mobile_phone             nil
    end
  end
end
