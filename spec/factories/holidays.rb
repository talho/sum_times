require 'faker'

FactoryGirl.define do
  factory :holiday do
    name { "#{Faker::Name.name} day" }
  end

  trait :starting_tomorrow do
    start_date { Date.today + 1.day }
  end
end
