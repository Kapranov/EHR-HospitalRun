FactoryGirl.define do
  factory :user do
    email                  { Faker::Internet.email }
    password              'provider'
    password_confirmation 'provider'
    role                  :Provider
    no_email              false

    factory :admin do
      role :Admin
    end

    factory :invalid_user do
      email nil
    end
  end
end
