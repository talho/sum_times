
FactoryGirl.define do
  factory :leave_transaction do
    date { Date.today }
    hours 8
  end

  trait :date_tomorrow do
    date { Date.today + 1.day }
  end
end
