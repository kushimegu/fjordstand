FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:uid) { |n| "123456789#{n}" }
    provider { "discord" }
    avatar_url { nil }
    admin { false }
  end

  trait :admin do
    admin { true }
  end
end
