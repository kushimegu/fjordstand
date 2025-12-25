FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence }
    user
    item
  end
end
