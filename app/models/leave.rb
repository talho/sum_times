class Leave < ActiveRecord::Base
  belongs_to :user

  attr_accessible :approved, :end_date, :hours, :start_date, :user_id, :reason, :category

  attr_accessor :date_hours

  after_save :notify_timesheet
  after_destroy :notify_timesheet

  after_initialize :init_accessors
  after_update :create_leave_transaction

  scope :unapproved, where("approved IS NOT true")

  def hours(date = nil)
    @date_hours[date] ||= self[:hours] || Schedule.total_hours(self.user_id, (date || self.start_date), (date || self.end_date))
  end

  private
  def init_accessors
    @date_hours = {}
  end

  def create_leave_transaction
    if self.approved_changed? && self.approved?
      LeaveTransaction.create(user_id: self.user_id, category: self.category, date: self.start_date, hours: -1 * self.hours)
    end
  end

  def notify_timesheet
    Timesheet.leave_added(self)
  end
end
