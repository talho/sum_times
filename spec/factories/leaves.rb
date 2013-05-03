
FactoryGirl.define do
  factory :leave do
    start_date { 1.day.from_now }
    user
  end

  trait :vacation do
    category 'vacation'
  end

  trait :sick do
    category 'sick'
  end

  trait :with_hours do
    hours 4
  end

  trait :with_end_date do
    end_date {2.days.from_now}
  end
end
