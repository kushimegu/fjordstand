FactoryBot.define do
  factory :notification do
    read { false }
    user

    trait :for_item do
      association :notifiable, factory: :item
    end

    trait :for_entry do
      association :notifiable, factory: :entry
    end

    trait :for_message do
      association :notifiable, factory: :message
    end

    trait :for_comment do
      association :notifiable, factory: :comment 
    end

    trait :read do
      read { true }
    end
  end
end
