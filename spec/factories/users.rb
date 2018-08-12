FactoryBot.define do
  factory :user, class: "User" do
    sequence(:email, 1) { |n| "user#{n}@example.com" }
  end
end
