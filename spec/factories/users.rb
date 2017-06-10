FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'passw0rd' }

    trait :by_twitter do
      uid { SecureRandom.hex(8) }
      provider { 'twitter' }
      password { nil }
    end
  end
end
