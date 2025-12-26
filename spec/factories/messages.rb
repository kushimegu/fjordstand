FactoryBot.define do
  factory :message do
    body { Faker::Lorem.sentence }
    user
    item
  end
end
