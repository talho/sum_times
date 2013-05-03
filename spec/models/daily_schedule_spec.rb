require 'spec_helper'

describe DailySchedule do
  before :each do
    @daily_schedule = DailySchedule.new
  end

  it "initializes a blank schedule" do
    @daily_schedule.instance_variable_get('@schedule').should eq({}.with_indifferent_access)
  end

  it "retrieves an initialized object for an empty date" do
    @daily_schedule[Date.today].should eq({schedules: [], holidays: [], leaves: []}.with_indifferent_access)
  end

  it "assigns values to schedule on change" do
    @daily_schedule[Date.today][:schedules] = [1]
    @daily_schedule.instance_variable_get('@schedule').should eq({Date.today => {schedules: [1], holidays: [], leaves: []}.with_indifferent_access}.with_indifferent_access)
  end
end
