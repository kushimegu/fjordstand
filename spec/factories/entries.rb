FactoryBot.define do
  factory :entry do
    status { %i[applied won lost].sample }

    association :user
    association :item
  end
end
