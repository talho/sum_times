class DailySchedule
  attr_accessor :schedule

  def initialize
    @schedule = {}
  end

  def [](date)
    @schedule[date] ||= {schedules: [], holidays: [], leaves: []}
  end
end
