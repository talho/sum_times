class Schedule < ActiveRecord::Base
  attr_accessible :end_date, :start_date, :user_id

  belongs_to :user

  after_save :close_previous_schedule

  def days
    self[:days].nil? ? {} : JSON.parse(self[:days])
  end

  def days=(in_days)
    in_days.each do |key, val|
      val["hours"] = (val["start"].blank? || val["end"].blank?) ? 0 : ((Time.parse(val["end"]) - Time.parse(val["start"]))/3600 - val["lunch"].to_i)
    end
    self[:days] = in_days.to_json
  end

  private
  def close_previous_schedule
    schedule = Schedule.where(user_id: self.user_id, end_date: nil).where("start_date < ?", self.start_date).order("start_date DESC").first # make this a bit smarter to ensure that schedules can't overlap
    schedule.update_attributes(end_date: self.start_date) unless schedule.nil?
  end
end
