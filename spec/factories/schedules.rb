
FactoryGirl.define do
  factory :schedule do
    start_date { 1.month.ago.to_date }
    user
    days( {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"}}
        )
  end

  trait :empty_schedule do
    days nil
  end

  trait :increasing_schedule do
    days( {"0"=>{"start"=>"10:00 AM", "end"=>"03:00 PM", "lunch"=>"1"},
           "1"=>{"start"=>"10:00 AM", "end"=>"04:00 PM", "lunch"=>"1"},
           "2"=>{"start"=>"09:00 AM", "end"=>"04:00 PM", "lunch"=>"1"},
           "3"=>{"start"=>"09:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "5"=>{"start"=>"08:00 AM", "end"=>"06:00 PM", "lunch"=>"1"},
           "6"=>{"start"=>"07:00 AM", "end"=>"06:00 PM", "lunch"=>"1"}}
        )
  end

  trait :no_lunch_schedule do
    days( {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0"},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0"},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0"},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0"},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0"},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0"},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0"}}
        )
  end

  trait :half_lunch_schedule do
    days( {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5"},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5"},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5"},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5"},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5"},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5"},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5"}}
        )
  end

  trait :two_week_schedule do
    days( {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "7"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "8"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "9"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "10"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "11"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "12"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"},
           "13"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1"}}
        )
  end
end
