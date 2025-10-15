FactoryBot.define do
  factory :user do
    name { "Alice" }
    sequence(:uid) { |n| "123456789#{n}" }
    provider { "discord" }
    avatar_url { "https://example.com/avatar.png" }
  end
end
