FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:uid) { |n| "123456789#{n}" }
    provider { "discord" }
    avatar_url { Faker::Avatar.image }
  end
end
