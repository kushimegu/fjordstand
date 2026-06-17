FactoryBot.define do
  factory :entry do
    status { :applied }
    user
    association :item, factory: :item, status: :published

    trait :won do
      status { :won }
    end

    trait :lost do
      status { :lost }
    end
  end
end
