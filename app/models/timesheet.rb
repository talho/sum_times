class Timesheet < ActiveRecord::Base
  attr_accessible :approval_date, :month, :supervisor_id, :user_id
end
