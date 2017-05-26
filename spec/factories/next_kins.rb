FactoryGirl.define do
  factory :next_kin do
    association       :patient
    first_name        { Faker::Name.first_name }
    last_name         { Faker::Name.last_name  }
    middle_name       { Faker::Name.first_name }
    relation          { EmergencyContact.relations.sample }
    mobile_phone      { PhonyRails.normalize_number(Faker::PhoneNumber.cell_phone, country_code: 'US') }
    email             { Faker::Internet.email }
    street_address    { Faker::Address.street_name }
    city              { 'Holtsville' }
    state             { 'New York' }
    zip               { '5500' }
  end
end
