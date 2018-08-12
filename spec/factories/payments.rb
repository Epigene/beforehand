FactoryBot.define do
  factory :payment, class: "Payment" do
    user { create(:user) }
    amount 1
  end
end
