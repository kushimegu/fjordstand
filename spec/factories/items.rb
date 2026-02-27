FactoryBot.define do
  factory :item do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Number.between(from: 100, to: 10_000) }
    shipping_fee_payer { %i[buyer seller].sample }
    payment_method { Faker::Lorem.sentence }
    entry_deadline_at { Faker::Date.forward(days: 30).end_of_day }
    status { :draft }
    user

    trait :published do
      status { :published }
    end

    trait :sold do
      status { :sold }
    end

    trait :closed do
      status { :closed }
    end

    trait :with_max_five_images do
      after(:build) do |item|
        rand(1..5).times do |n|
          item.images.attach(
            io: File.open(Rails.root.join("spec/fixtures/files/book#{(n % 5) + 1}.png")),
            filename: "book#{(n % 5) + 1}.png",
            content_type: 'image/png'
          )
        end
      end
    end

    trait :with_three_images do
      after(:build) do |item|
        3.times do |n|
          item.images.attach(
            io: File.open(Rails.root.join("spec/fixtures/files/book#{n + 1}.png")),
            filename: "book#{n + 1}.png",
            content_type: 'image/png'
          )
        end
      end
    end
  end
end
