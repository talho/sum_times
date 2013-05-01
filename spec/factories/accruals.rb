
FactoryGirl.define do
  factory :accrual do
    month { rand(1..12) }
    year { rand(2012..2014) }
  end
end
