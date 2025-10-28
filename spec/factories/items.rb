FactoryBot.define do
  factory :item do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.between(from: 100, to: 10_000) }
    shipping_fee_payer { %i[buyer seller].sample }
    payment_method { Faker::Lorem.sentence }
    entry_deadline_at { Faker::Date.forward(days: 30).end_of_day }
    status { %i[draft published sold closed].sample }

    association :user

    trait :with_max_five_images do
      before(:create) do |item|
        rand(1..5).times do |n|
          item.images.attach(
            io: File.open(Rails.root.join("spec/fixtures/test#{(n % 5) + 1}.png")),
            filename: "test#{(n % 5) + 1}.png",
            content_type: 'image/png'
          )
        end
      end
    end

    trait :with_three_images do
      before(:create) do |item|
        3.times do |n|
          item.images.attach(
            io: File.open(Rails.root.join("spec/fixtures/test#{n + 1}.png")),
            filename: "test#{n + 1}.png",
            content_type: 'image/png'
          )
        end
      end
    end
  end
end
