class Timesheet < ActiveRecord::Base
  attr_accessible :month, :year, :user_id, :user_approved, :supervisor_approved, :schedule, :ready_for_submission

  validates :user_id, :presence => true
  validates :month, :presence => true, :uniqueness => {:scope => [:year, :user_id]}, :numericality => {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12}
  validates :year, :presence => true, :numericality => { only_integer: true, greater_than_or_equal_to: 1900 }

  before_create :generate_schedule

  belongs_to :user

  scope :waiting_for_user, where(user_approved: nil, supervisor_approved: nil)
  scope :waiting_for_supervisor, where(user_approved: true, supervisor_approved: nil)

  def schedule
    @schedule ||= self[:schedule].blank? ? {} : JSON.parse(self[:schedule])
  end

  def schedule=(val)
    @schedule = val
    self[:schedule] = @schedule.to_json
  end

  def generate_schedule
    return if self.month.nil? || self.year.nil?
    month_date = Date.today.at_beginning_of_month.change(:month => self.month, :year => self.year)
    self.build_schedule(month_date.at_beginning_of_month, month_date.at_end_of_month)
  end

  def self.leave_added(leave)
    self.update_from_change(leave.user_id, leave.start_date, leave.end_date || leave.start_date)
  end

  def self.schedule_changed(sched)
    self.update_from_change(sched.user_id, sched.start_date, sched.end_date || (sched.start_date + 100.years) ) # this is a sliding large number of years to ensure we get all timesheets.
                                                                                                                # really, don't generate timesheets for 100 years in the future or schedules
                                                                                                                # stretching back 100 years.
  end

  protected

  def self.update_from_change(user_id, start_date, end_date)
    timesheets = Timesheet.where(user_id: user_id)
    timesheets = timesheets.where("(month >= :start_month AND year = :start_year OR year > :start_year) AND (month <= :end_month AND year = :end_year OR year < :end_year)",
                  start_month: start_date.month, end_month: end_date.month, start_year: start_date.year, end_year: end_date.year)

    timesheets.each do |ts|
      # recaculate timesheet with leave in place
      local_start = start_date.month == ts.month && start_date.year == ts.year ? start_date : Date.new(ts.year, ts.month, 1)
      local_end = end_date.month == ts.month && end_date.year == ts.year ? end_date : local_start.at_end_of_month
      ts.send :build_schedule, local_start, local_end
      ts.save
    end
  end

  def build_schedule(start_date, end_date)
    sched_days = Schedule.over_dates(start_date, end_date).where(user_id: self.user_id)
    holder = self.schedule
    self.total_hours = self.worked_hours = self.holiday_hours = self.vacation_hours = self.sick_hours = self.admin_hours = self.unpaid_hours = 0
    sched_days.each do |sched|
      leaves = Leave.where(user_id: self.user_id).where("start_date = :date OR (start_date >= :date AND end_date <= :date)", date: sched.date)
      holiday = Holiday.where("start_date = :date OR (start_date >= :date AND end_date <= :date)", date: sched.date).first
      vac = leaves.select{|l| l.category == 'vacation'}.map{ |l| l.hours(sched.date)}.sum
      sick = leaves.select{|l| l.category == 'sick'}.map{ |l| l.hours(sched.date)}.sum
      admin = leaves.select{|l| l.category == 'admin'}.map{ |l| l.hours(sched.date)}.sum
      unpaid = leaves.select{|l| l.category == 'unpaid'}.map{ |l| l.hours(sched.date)}.sum
      holiday = holiday.present? ? 8 : 0
      norm = [sched.hours  - vac - sick - admin - unpaid - holiday, 0].max
      holder[sched.date.to_s] = {'worked_hours' => norm, 'vacation_hours' => vac, 'sick_hours' => sick, 'admin_hours' => admin, 'unpaid_hours' => unpaid, 'holiday_hours' => holiday}
    end

    # recalculate totals
    holder.each do |k, v|
      self.vacation_hours += v['vacation_hours']
      self.sick_hours += v['sick_hours']
      self.admin_hours += v['admin_hours']
      self.unpaid_hours += v['unpaid_hours']
      self.holiday_hours += v['holiday_hours']
      self.worked_hours += v['worked_hours']
      self.total_hours += v['vacation_hours'] + v['sick_hours'] + v['admin_hours'] + v['holiday_hours'] + v['worked_hours']
    end

    self.schedule = Hash[holder.sort]
  end
end
