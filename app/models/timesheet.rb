class Timesheet < ActiveRecord::Base
  attr_accessible :month, :user_id, :user_approved, :supervisor_approved, :schedule

  validate :user_id, :presence => true
  validate :month, :uniqueness => {:scope => :user_id}, :numericality => {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12}

  before_create :generate_schedule

  belongs_to :user

  scope :waiting_for_user, where(user_approved: nil, supervisor_approved: nil)
  scope :waiting_for_supervisor, where(user_approved: true, supervisor_approved: nil)

  def schedule
    JSON.parse(self[:schedule])
  end

  def schedule=(val)
    self[:schedule] = val.to_json
  end

  def generate_schedule
    month_date = Date.today.at_beginning_of_month.change(:month => self.month, :year => self.year)
    sched_days = Schedule.over_dates(month_date.at_beginning_of_month, month_date.at_end_of_month).where(user_id: self.user_id)
    holder = {}
    self.total_hours = self.worked_hours = self.holiday_hours = self.vacation_hours = self.sick_hours = self.admin_hours = self.unpaid_hours = 0
    sched_days.each do |sched|
      if sched.hours > 0
        leaves = Leave.where(user_id: self.user_id).where("start_date = :date OR (start_date >= :date AND end_date <= :date)", date: sched.date)
        holiday = Holiday.where("start_date = :date OR (start_date >= :date AND end_date <= :date)", date: sched.date).first
        self.vacation_hours += vac = leaves.select{|l| l.category == 'vacation'}.map(&:hours).sum
        self.sick_hours += sick = leaves.select{|l| l.category == 'sick'}.map(&:hours).sum
        self.admin_hours += admin = leaves.select{|l| l.category == 'admin'}.map(&:hours).sum
        self.unpaid_hours += unpaid = leaves.select{|l| l.category == 'unpaid'}.map(&:hours).sum
        self.holiday_hours += holiday = holiday.present? ? 8 : 0
        self.worked_hours += norm = [sched.hours  - vac - sick - admin - unpaid - holiday, 0].max
        self.total_hours += vac + sick + admin + holiday + norm
        holder[sched.date] = {worked_hours: norm, vacation_hours: vac, sick_hours: sick, admin_hours: admin, unpaid_hours: unpaid, holiday_hours: holiday}
      end
    end
    self.schedule = holder
  end
end
