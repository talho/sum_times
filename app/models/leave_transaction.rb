class LeaveTransaction < ActiveRecord::Base
  attr_accessible :category, :hours, :user_id, :date

  validates :user_id, :presence => true
  validates :date, :presence => true
  validates :hours, :presence => true, :numericality => true
end
