FactoryBot.define do
  factory :entry do
    status { :applied }
    user
    item

    trait :won do
      status { :won }
    end

    trait :lost do
      status { :lost }
    end
  end
end
