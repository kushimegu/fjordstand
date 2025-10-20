FactoryBot.define do
  factory :item do
    user { nil }
    title { "MyString" }
    description { "MyText" }
    price { 1 }
    shipping_fee_payer { 1 }
    payment_method { "MyString" }
    entry_deadline_at { "2025-10-17 15:40:33" }
    status { 1 }
  end
end
