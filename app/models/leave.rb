class Leave < ActiveRecord::Base
  attr_accessible :approved, :end_date, :hours, :start_date, :user_id, :reason
end
