
FactoryGirl.define do
  factory :timesheet do
    user
    month { Date.tomorrow.month }
    year { Date.tomorrow.year }
  end
end
