require "faker"

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.safe_email }
    name {Faker::Name.name }
    password 'Password1'
    password_confirmation 'Password1'
  end
end
