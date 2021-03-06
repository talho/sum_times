class Schedule < ActiveRecord::Base
  attr_accessor :date
  attr_accessible :end_date, :start_date, :user_id, :date

  belongs_to :user

  after_save :close_previous_schedule
  after_save :notify_timesheet

  def days
    @days ||= self[:days].nil? ? {} : JSON.parse(self[:days])
  end

  def days=(in_days)
    in_days.each do |key, val|
      val["hours"] = (val["start"].blank? || val["end"].blank?) ? 0 : ((Time.parse(val["end"]) - Time.parse(val["start"]))/3600 - val["lunch"].to_f)
    end unless in_days.nil?
    self[:days] = in_days.nil? ? nil : in_days.to_json
  end

  def date=(in_date)
    @date = in_date.is_a?(Date) ? in_date : Date.parse(in_date)
  end

  def date
    @date ||= self[:date] ? Date.parse(self[:date]) : nil
  end

  def date_index
    (self.date - (self.start_date - self.start_date.days_to_week_start(:sunday))).to_i % self.days.length
  end

  def start
    self.days[self.date_index.to_s]["start"]
  end

  def end
    self.days[self.date_index.to_s]["end"]
  end

  def hours
    self.days[self.date.days_to_week_start(:sunday).to_s]["hours"]
  end

  def self.over_dates(start_date, end_date)
    end_date ||= start_date
    self.select("schedules.*, dates.date")
        .joins("JOIN generate_series('#{start_date.to_s}', '#{end_date.to_s}', INTERVAL '1 day') as dates ON dates.date >= schedules.start_date AND
                                                                                                            (dates.date <= schedules.end_date OR schedules.end_date IS NULL)")
  end

  def self.total_hours(user_id, start_date, end_date)
    holidays = Holiday.where("(start_date >= :start AND start_date <= :end AND end_date IS NULL) OR (start_date >= :start AND end_date <= :end)", :start => start_date, :end => end_date)
    self.over_dates(start_date, end_date).where(user_id: user_id).select{|s| holidays.index{|h| h.start_date == s.date || (!h.end_date.nil? && h.start_date <= s.date && h.end_date >= s.date)}.nil?}.map(&:hours).sum
  end

  private
  def close_previous_schedule
    schedules = Schedule.where(user_id: self.user_id).where("id != ?", self.id)
    if self.end_date.nil?
      # find any that start before and don't end or end after and modify to end
      schedules.where("start_date < :start AND (end_date IS NULL OR end_date >= :start)", start: self.start_date).each do |schedule|
        schedule.update_attributes end_date: (self.start_date - 1.day)
      end

      # find any that start after and destroy
      schedules.where("start_date >= :start", start: self.start_date).destroy_all
    else
      # find any that start before and don't end and end and dupilicate
      schedules.where("start_date < :start AND (end_date IS NULL OR end_date > :end)", start: self.start_date, end: self.end_date).each do |schedule|
        new_sched = schedule.dup
        new_sched.start_date = self.end_date + 1.day

        schedule.update_attributes end_date: (self.start_date - 1.day)
        new_sched.save
      end

      # find any that are wholly contained and destroy
      schedules.where("start_date >= :start AND end_date <= :end", start: self.start_date, end: self.end_date).destroy_all

      # find any that are partially contained and modify
      schedules.where("start_date < :start AND end_date >= :start AND end_date <= :end", start: self.start_date, end: self.end_date).each do |schedule|
        schedule.update_attributes end_date: (self.start_date - 1.day)
      end
      schedules.where("start_date >= :start AND start_date <= :end AND (end_date > :end OR end_date IS NULL)", start: self.start_date, end: self.end_date).each do |schedule|
        schedule.update_attributes start_date: (self.end_date + 1.day)
      end
    end
  end

  def notify_timesheet
    Timesheet.schedule_changed(self)
  end
end
