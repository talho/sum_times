class DailySchedule
  attr_accessor :schedule

  def initialize
    @schedule = {}.with_indifferent_access
  end

  def [](date)
    @schedule[date] ||= {schedules: [], holidays: [], leaves: []}.with_indifferent_access
  end
end
