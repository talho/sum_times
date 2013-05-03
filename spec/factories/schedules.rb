
FactoryGirl.define do
  factory :schedule do
    start_date { 1.month.ago.to_date }
    user
    days( {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours"=>8.0},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours"=>8.0},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours"=>8.0},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours"=>8.0},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours"=>8.0},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours"=>8.0},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours"=>8.0}}
        )
  end
end
