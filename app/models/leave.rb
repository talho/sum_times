class Leave < ActiveRecord::Base
  belongs_to :user

  attr_accessible :approved, :end_date, :hours, :start_date, :user_id, :reason, :category

  attr_accessor :date_hours

  after_initialize :init_accessors

  def hours(date = nil)
    @date_hours[date] ||= self[:hours] || Schedule.total_hours(self.user_id, (date || self.start_date), (date || self.end_date))
  end

  private
  def init_accessors
    @date_hours = {}
  end
end
