FactoryBot.define do
  factory :entry do
    status { %i[pending won lost].sample }

    association :user
    association :item
  end
end
