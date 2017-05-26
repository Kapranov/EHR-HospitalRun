FactoryGirl.define do
  factory :location do
    provider_id              { nil }
    location_name            { Faker::Address.street_name }
    location_phone           { PhonyRails.normalize_number(Faker::PhoneNumber.cell_phone, country_code: 'US') }
    location_fax             { PhonyRails.normalize_number(Faker::PhoneNumber.cell_phone, country_code: 'US') }
    location_address         { Faker::Address.street_name }
    location_npi             { Faker::Company.ein }
    location_tin_en          { Faker::Company.ein }
    colour                   { Activation.colour }
    city                     { 'Holtsville' }
    state                    { 'New York' }
    zip                      { '5500' }
  end
end
