class Schedule < ActiveRecord::Base
  attr_accessible :end_date, :days, :start_date, :user_id
end
