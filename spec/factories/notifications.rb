FactoryBot.define do
  factory :notification do
    read { false }

    association :user

    trait :for_item do
      association :notifiable, factory: :item
    end

    trait :for_entry do
      association :notifiable, factory: :entry
    end

    trait :for_message do
      association :notifiable, factory: :message
    end
  end
end
