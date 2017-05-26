FactoryGirl.define do
  factory :claim do
    association     :payer
    first_name      { Faker::Name.first_name }
    middle_name     { Faker::Name.first_name }
    last_name       { Faker::Name.last_name  }
    street_address1 { Faker::Address.street_address }
    street_address2 { Faker::Address.street_address }
    phone           { PhonyRails.normalize_number(Faker::PhoneNumber.cell_phone, country_code: 'US') }
    fax             { PhonyRails.normalize_number(Faker::PhoneNumber.cell_phone, country_code: 'US') }
    ext1            { Faker::Hipster.word }
    ext2            { Faker::Hipster.word }
    notes           { Faker::Hipster.sentence }
  end
end
