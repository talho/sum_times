class Holiday < ActiveRecord::Base
  attr_accessible :end_date, :name, :start_date
end
