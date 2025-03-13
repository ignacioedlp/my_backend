FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Time.current }

    trait :admin do
      after(:create) { |user| user.add_role(:admin) }
    end

    trait :banned do
      banned { true }
      ban_reason { "Violation of terms" }
      banned_at { Time.current }
    end
  end
end
