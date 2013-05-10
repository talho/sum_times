require 'spec_helper'

describe Timesheet do
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :month }
  it { should validate_numericality_of(:month).only_integer }
  it { should validate_uniqueness_of(:month).scoped_to(:user_id, :year) }
  it { should validate_presence_of :year }
  it { should validate_numericality_of(:year).only_integer }
  it { should belong_to :user }

  describe ".schedule" do
    context "schedule is blank" do
      Given(:ts) { Timesheet.new }
      Then { ts.schedule.should eq({}) }
    end

    context "set schedule" do
      Given(:timesheet) { FactoryGirl.create :timesheet }

      When { timesheet.schedule = {"asdf" => "bbva"} }
      When { timesheet.save }

      Then { timesheet.schedule.should eq({"asdf" => "bbva"}) }
      And  { Timesheet.find(timesheet.id).schedule.should eq({"asdf" => "bbva"}) }
    end
  end

  describe ".generate_schedule" do
    before :each do
      Timesheet.any_instance.stub(:build_schedule).with(an_instance_of(Date), an_instance_of(Date))
    end

    it "doesn't receive build_schedule when year is nil" do
      timesheet = FactoryGirl.build :timesheet, year: nil
      timesheet.should_not_receive(:build_schedule)
      timesheet.generate_schedule
    end

    it "doesn't receive build_schedule when month is nil" do
      timesheet = FactoryGirl.build :timesheet, month: nil
      timesheet.should_not_receive(:build_schedule)
      timesheet.generate_schedule
    end

    it "receives build_schedule when month and year are set" do
      timesheet = FactoryGirl.build :timesheet, month: 3, year: 2012
      timesheet.should_receive(:build_schedule).with(Date.parse("2012-03-01"), Date.parse("2012-03-31"))
      timesheet.generate_schedule
    end
  end

  context "messengers" do
    before :each do
      Timesheet.stub(:update_from_change).with(an_instance_of(Integer), an_instance_of(Date), an_instance_of(Date))
    end

    describe ".leave_added" do
      def call_leave_added
        Timesheet.leave_added(leave)
      end

      Given(:leave) { FactoryGirl.build :leave, start_date: start_date, end_date: end_date }
      Given(:start_date) { Date.today }
      When { Timesheet.should_receive(:update_from_change).with(leave.user_id, start_date, end_date || start_date)}

      context "leave with single date" do
        Given(:end_date) { nil }
        Then { call_leave_added }
      end

      context "leave with end date" do
        Given(:end_date) { Date.tomorrow }
        Then { call_leave_added }
      end
    end

    describe ".schedule_changed" do
      def call_schedule_changed
        Timesheet.schedule_changed(schedule)
      end

      Given(:schedule) { FactoryGirl.build :schedule, start_date: start_date, end_date: end_date }
      Given(:start_date) { Date.today }
      When { Timesheet.should_receive(:update_from_change).with(schedule.user_id, start_date, end_date || (start_date + 100.years)) }

      context "schedule with single date" do
        Given(:end_date) { nil }
        Then { call_schedule_changed }
      end

      context "schedule with end date" do
        Given(:end_date) { Date.tomorrow }
        Then { call_schedule_changed }
      end
    end
  end

  describe ".update_from_change" do
    When do
      @called = 0
      Timesheet.any_instance.stub(:build_schedule) do |sd, ed|
        @called += 1 if sd == expected_start_date && ed == expected_end_date
      end
    end

    def call_update_from_change
      Timesheet.update_from_change(user.id, start_date, end_date)
    end

    Given(:start_date) { Date.today }
    Given(:end_date) { Date.today + 100.years }
    Given(:user) { FactoryGirl.create :user }

    context "don't update out of scope timesheets" do
      Given(:end_date) { Date.today + 1.month }
      Given!(:timesheet) { FactoryGirl.create :timesheet, user: user, month: (start_date - 1.month).month, year: (start_date - 1.month).year }
      Given!(:timesheet2) { FactoryGirl.create :timesheet, user: user, month: (start_date + 2.months).month, year: (start_date + 2.months).year }

      When do
        Timesheet.any_instance.stub(:build_schedule) do |sd, ed|
          @called += 1 if sd == expected_start_date && ed == expected_end_date
        end
      end
      When { call_update_from_change }

      Then { @called.should eq 0 }
    end

    context "update one timesheet" do
      Given!(:timesheet) { FactoryGirl.create :timesheet, user: user, month: start_date.month, year: start_date.year }
      Given(:expected_start_date) { start_date }
      Given(:expected_end_date) { start_date.at_end_of_month }

      When { call_update_from_change }

      Then { @called.should eq 1 }
    end

    context "update timesheet at beginning of limited search" do
      Given(:end_date) { Date.today + 1.month }
      Given!(:timesheet) { FactoryGirl.create :timesheet, user: user, month: start_date.month, year: start_date.year }
      Given(:expected_start_date) { start_date }
      Given(:expected_end_date) { start_date.at_end_of_month }

      When { call_update_from_change }

      Then { @called.should eq 1 }
    end

    context "update timesheet at end of limited search" do
      Given!(:timesheet) { FactoryGirl.create :timesheet, user: user, month: end_date.month, year: end_date.year }
      Given(:expected_start_date) { end_date.at_beginning_of_month }
      Given(:expected_end_date) { end_date }

      When { call_update_from_change }

      Then { @called.should eq 1 }
    end

    context "update timesheet in middle of long search" do # this reflects the long end date that timesheet sets when end date is nil
      Given!(:timesheet) { FactoryGirl.create :timesheet, user: user, month: (start_date + 10.months).month, year: (start_date + 10.months).year }
      Given(:expected_start_date) { (start_date + 10.months).at_beginning_of_month }
      Given(:expected_end_date) { (start_date + 10.months).at_end_of_month }

      When { call_update_from_change }

      Then { @called.should eq 1 }
    end
  end

  describe ".build_schedule" do
    context "build basic schedule" do
      Given(:schedule) { FactoryGirl.create :schedule, start_date: Date.new(2013, 4, 1), end_date: Date.new(2013, 8, 1) }
      Given(:timesheet) { FactoryGirl.build :timesheet, user: schedule.user, month: 5, year: 2013 }

      When { timesheet.send :build_schedule, Date.new(2013, 5, 1), Date.new(2013, 5, 31) }

      Then { timesheet.schedule.should eq({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-02" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-12" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-13" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-14" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-15" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-16" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-17" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-18" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-19" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-20" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-21" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-22" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-23" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-24" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-25" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-26" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-27" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-28" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-29" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-30" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-31" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}}) }
      And  { timesheet.vacation_hours.should eq 0 }
      And  { timesheet.sick_hours.should eq 0 }
      And  { timesheet.admin_hours.should eq 0 }
      And  { timesheet.unpaid_hours.should eq 0 }
      And  { timesheet.holiday_hours.should eq 0 }
      And  { timesheet.worked_hours.should eq 248.0 }
      And  { timesheet.total_hours.should eq 248.0 }
    end

    context "build schedule with 2 different source schedules" do
      Given!(:schedule) { FactoryGirl.create :schedule, start_date: Date.new(2013, 4, 1), end_date: Date.new(2013, 5, 11) }
      Given!(:schedule2) { FactoryGirl.create :schedule, :no_lunch_schedule, user: schedule.user, start_date: Date.new(2013, 5, 12), end_date: Date.new(2013, 8, 1) }
      Given(:timesheet) { FactoryGirl.build :timesheet, user: schedule.user, month: 5, year: 2013 }

      When { timesheet.send :build_schedule, Date.new(2013, 5, 1), Date.new(2013, 5, 31) }

      Then { timesheet.schedule.should eq({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-02" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-12" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-13" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-14" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-15" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-16" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-17" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-18" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-19" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-20" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-21" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-22" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-23" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-24" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-25" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-26" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-27" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-28" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-29" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-30" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-31" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}}) }
      And  { timesheet.worked_hours.should eq 268.0 }
      And  { timesheet.total_hours.should eq 268.0 }
    end

    context "update schedule" do
      Given!(:schedule) { FactoryGirl.create :schedule, start_date: Date.new(2013, 4, 1) }
      Given(:timesheet) { FactoryGirl.build :timesheet, user: schedule.user, month: 5, year: 2013}

      When { timesheet.send :build_schedule, Date.new(2013, 5, 1), Date.new(2013, 5, 31) }

      it "should be update part of a schedule" do
        timesheet.schedule.should eq({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-02" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-12" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-13" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-14" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-15" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-16" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-17" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-18" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-19" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-20" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-21" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-22" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-23" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-24" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-25" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-26" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-27" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-28" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-29" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-30" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-31" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}})

        FactoryGirl.create :schedule, :no_lunch_schedule, user: schedule.user, start_date: Date.new(2013, 5, 12)
        timesheet.send :build_schedule, Date.new(2013, 5, 12), Date.new(2013, 5, 31)

        timesheet.schedule.should eq({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-02" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-12" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-13" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-14" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-15" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-16" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-17" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-18" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-19" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-20" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-21" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-22" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-23" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-24" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-25" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-26" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-27" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-28" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-29" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-30" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
         "2013-05-31" => {"worked_hours"=>9.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}})
      end
    end

    context "build schdule with leave" do
      Given(:schedule) { FactoryGirl.create :schedule, start_date: Date.new(2013, 4, 1), end_date: Date.new(2013, 8, 1) }
      Given(:timesheet) { FactoryGirl.build :timesheet, user: schedule.user, month: 5, year: 2013 }

      When { timesheet.send :build_schedule, Date.new(2013, 5, 1), Date.new(2013, 5, 31) }

      context "vacation" do
        Given!(:vacaion) { FactoryGirl.create :leave, :vacation, user: schedule.user, start_date: Date.new(2013,5,2) }

        Then { timesheet.schedule.should eq ({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-02" => {"worked_hours"=>0.0, "vacation_hours"=>8.0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-12" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-13" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-14" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-15" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-16" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-17" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-18" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-19" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-20" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-21" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-22" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-23" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-24" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-25" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-26" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-27" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-28" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-29" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-30" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-31" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}}) }
        And  { timesheet.vacation_hours.should eq 8 }
        And  { timesheet.worked_hours.should eq 240.0 }
        And  { timesheet.total_hours.should eq 248.0 }
      end

      context "sick" do
        Given!(:sick) { FactoryGirl.create :leave, :sick, user: schedule.user, start_date: Date.new(2013,5,2) }

        Then { timesheet.schedule.should eq ({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-02" => {"worked_hours"=>0.0, "vacation_hours"=>0, "sick_hours"=>8.0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-12" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-13" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-14" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-15" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-16" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-17" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-18" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-19" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-20" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-21" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-22" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-23" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-24" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-25" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-26" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-27" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-28" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-29" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-30" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-31" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}}) }
        And  { timesheet.sick_hours.should eq 8 }
        And  { timesheet.worked_hours.should eq 240.0 }
        And  { timesheet.total_hours.should eq 248.0 }
      end

      context "admin" do
        Given!(:admin) { FactoryGirl.create :leave, :admin, user: schedule.user, start_date: Date.new(2013,5,2) }

        Then { timesheet.schedule.should eq ({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-02" => {"worked_hours"=>0.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>8.0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-12" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-13" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-14" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-15" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-16" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-17" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-18" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-19" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-20" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-21" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-22" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-23" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-24" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-25" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-26" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-27" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-28" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-29" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-30" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-31" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}}) }
        And  { timesheet.admin_hours.should eq 8 }
        And  { timesheet.worked_hours.should eq 240.0 }
        And  { timesheet.total_hours.should eq 248.0 }
      end

      context "unpaid" do
        Given!(:unpaid) { FactoryGirl.create :leave, :unpaid, user: schedule.user, start_date: Date.new(2013,5,2) }

        Then { timesheet.schedule.should eq ({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-02" => {"worked_hours"=>0.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>8.0, "holiday_hours"=>0},
       "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-12" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-13" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-14" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-15" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-16" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-17" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-18" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-19" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-20" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-21" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-22" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-23" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-24" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-25" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-26" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-27" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-28" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-29" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-30" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-31" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}}) }
        And  { timesheet.unpaid_hours.should eq 8 }
        And  { timesheet.worked_hours.should eq 240.0 }
        And  { timesheet.total_hours.should eq 240.0 }
      end

      context "holiday" do
        Given!(:holiday) { FactoryGirl.create :holiday, name: "Memorial Day", start_date: Date.new(2013, 5, 27) }

        Then { timesheet.schedule.should eq ({"2013-05-01" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-02" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-03" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-04" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-05" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-06" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-07" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-08" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-09" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-10" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-11" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-12" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-13" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-14" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-15" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-16" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-17" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-18" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-19" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-20" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-21" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-22" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-23" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-24" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-25" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-26" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-27" => {"worked_hours"=>0.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>8.0},
       "2013-05-28" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-29" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-30" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0},
       "2013-05-31" => {"worked_hours"=>8.0, "vacation_hours"=>0, "sick_hours"=>0, "admin_hours"=>0, "unpaid_hours"=>0, "holiday_hours"=>0}}) }
        And  { timesheet.holiday_hours.should eq 8 }
        And  { timesheet.worked_hours.should eq 240.0 }
        And  { timesheet.total_hours.should eq 248.0 }
      end
    end
  end
end
