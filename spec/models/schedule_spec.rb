require 'spec_helper'

describe Schedule do
  it { should belong_to :user }

  describe ".days" do
    Given(:schedule) { FactoryGirl.create :schedule, trait }

    context "empty" do
      Given(:trait) { :empty_schedule }
      Then { schedule.days.should == {} }
    end

    context "increasing" do
      Given(:trait) { :increasing_schedule }
      Then { schedule.days.should == {"0"=>{"start"=>"10:00 AM", "end"=>"03:00 PM", "lunch"=>"1", "hours" => 4.0},
           "1"=>{"start"=>"10:00 AM", "end"=>"04:00 PM", "lunch"=>"1", "hours" => 5.0},
           "2"=>{"start"=>"09:00 AM", "end"=>"04:00 PM", "lunch"=>"1", "hours" => 6.0},
           "3"=>{"start"=>"09:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 7.0},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "5"=>{"start"=>"08:00 AM", "end"=>"06:00 PM", "lunch"=>"1", "hours" => 9.0},
           "6"=>{"start"=>"07:00 AM", "end"=>"06:00 PM", "lunch"=>"1", "hours" => 10.0}}
           }
    end

    context "no lunch" do
      Given(:trait) { :no_lunch_schedule }
      Then { schedule.days.should == {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0", "hours" => 9.0},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0", "hours" => 9.0},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0", "hours" => 9.0},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0", "hours" => 9.0},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0", "hours" => 9.0},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0", "hours" => 9.0},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0", "hours" => 9.0}}
           }
    end

    context "half-hour lunch" do
      Given(:trait) { :half_lunch_schedule }
      Then { schedule.days.should == {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5", "hours" => 8.5},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5", "hours" => 8.5},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5", "hours" => 8.5},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5", "hours" => 8.5},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5", "hours" => 8.5},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5", "hours" => 8.5},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"0.5", "hours" => 8.5}}
           }
    end

    context "two-week" do
      Given(:trait) { :two_week_schedule }
      Then { schedule.days.should == {"0"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "1"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "2"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "3"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "4"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "5"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "6"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "7"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "8"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "9"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "10"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "11"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "12"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0},
           "13"=>{"start"=>"08:00 AM", "end"=>"05:00 PM", "lunch"=>"1", "hours" => 8.0}}
           }
    end

  end

  describe "date lookups" do
    Given(:sunday) { Date.today.at_beginning_of_week - 1.day }
    Given(:test_date) { sunday + offset.days }

    context "1 week schedule" do
      Given(:schedule) { FactoryGirl.create :schedule, :increasing_schedule, date: test_date }

      describe "Sunday" do
        Given(:offset) { 0 }
        Then { schedule.date_index.should eq 0}
        And  { schedule.start.should eq "10:00 AM"}
        And  { schedule.end.should eq "03:00 PM" }
        And  { schedule.hours.should eq 4.0 }
      end

      describe "Monday" do
        Given(:offset) { 1 }
        Then { schedule.date_index.should eq 1 }
      end

      describe "Tuesday" do
        Given(:offset) { 2 }
        Then { schedule.date_index.should eq 2 }
      end

      describe "Wednesday" do
        Given(:offset) { 3 }
        Then { schedule.date_index.should eq 3 }
      end

      describe "Thursday" do
        Given(:offset) { 4 }
        Then { schedule.date_index.should eq 4 }
      end

      describe "Friday" do
        Given(:offset) { 5 }
        Then { schedule.date_index.should eq 5 }
      end

      describe "Satuday" do
        Given(:offset) { 6 }
        Then { schedule.date_index.should eq 6 }
        And  { schedule.start.should eq "07:00 AM"}
        And  { schedule.end.should eq "06:00 PM" }
        And  { schedule.hours.should eq 10.0 }
      end

      describe "Next Sunday" do
        Given(:offset) { 7 }
        Then { schedule.date_index.should eq 0 }
        And  { schedule.start.should eq "10:00 AM"}
        And  { schedule.end.should eq "03:00 PM" }
        And  { schedule.hours.should eq 4.0 }
      end
    end

    context "2 week schedule" do
      Given(:schedule) { FactoryGirl.create :schedule, :two_week_schedule, start_date: sunday, date: test_date }

      describe "Sunday" do
        Given(:offset) { 0 }
        Then { schedule.date_index.should eq 0 }
      end

      describe "Next Sunday" do
        Given(:offset) { 7 }
        Then { schedule.date_index.should eq 7 }
      end

      describe "Sunday After" do
        Given(:offset) { 14 }
        Then { schedule.date_index.should eq 0 }
      end
    end
  end

  describe ".over_dates" do
    Given!(:schedule) { FactoryGirl.create :schedule }

    When(:over_dates) { Schedule.over_dates(Date.today, Date.today + 5.days).where(user_id: schedule.user_id) } # need to use schedule before the lazy given fires.
    Then { over_dates.should be_an ActiveRecord::Relation }
    And  { over_dates.all.count.should eq 6 }
    And  { over_dates.all.first.date.should eq Date.today }
    And  { over_dates.all.last.date.should eq(Date.today + 5.days) }
  end

  describe ".total_hours" do
    Given!(:schedule) { FactoryGirl.create :schedule }

    When(:total_hours) { Schedule.total_hours(schedule.user_id, Date.today, Date.today + 5.days) }

    Then { total_hours.should be_a Float}
    And  { total_hours.should eq 48.0 }

    context "with holiday" do
      Given!(:holidy) { FactoryGirl.create :holiday, :starting_tomorrow }

      Then { total_hours.should eq 40 }
    end
  end

  context "after_save" do
    describe ".close_previous_schedule" do
      context "without end date" do
        context "new schedule without end date" do
          Given!(:first_schedule) { FactoryGirl.create :schedule }
          Given!(:second_schedule) {FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.tomorrow }

          Then { first_schedule.reload.end_date.should eq Date.today }
        end

        context "new schedule without end destroys existing" do
          Given!(:first_schedule) { FactoryGirl.create :schedule, start_date: Date.tomorrow, end_date: Date.tomorrow + 1.day }
          Given!(:second_schedule) { FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.tomorrow + 2.days }
          Given!(:third_schedule) { FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.today }

          Then { Schedule.count.should eq 1 }
          And  { expect { first_schedule.reload }.to raise_error(ActiveRecord::RecordNotFound) }
          And  { expect { second_schedule.reload }.to raise_error(ActiveRecord::RecordNotFound) }
          And  { expect { third_schedule.reload }.to_not raise_error(ActiveRecord::RecordNotFound) }
        end
      end

      context "with end date" do
        context "new schedule with end date ends schedule with nil end_date, duplicates" do
          Given!(:first_schedule) { FactoryGirl.create :schedule }
          Given!(:second_schedule) {FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.tomorrow, end_date: Date.tomorrow + 3.days }

          When(:third_schedule) { Schedule.last }
          Then { first_schedule.reload.end_date.should eq Date.today }
          And  { third_schedule.start_date.should eq (Date.tomorrow + 4.days) }
          And  { third_schedule.end_date.should be_nil }
          And  { first_schedule.days.should eq third_schedule.days }
        end

        context "new schedule with end date ends schedule with outside end_date, duplicates" do
          Given!(:first_schedule) { FactoryGirl.create :schedule, end_date: Date.tomorrow + 10.days }
          Given!(:second_schedule) {FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.tomorrow, end_date: Date.tomorrow + 3.days }

          When(:third_schedule) { Schedule.last }
          Then { first_schedule.reload.end_date.should eq Date.today }
          And  { third_schedule.start_date.should eq (Date.tomorrow + 4.days) }
          And  { third_schedule.end_date.should eq (Date.tomorrow + 10.days) }
          And  { first_schedule.days.should eq third_schedule.days }
        end

        context "new schedule with end date removes wholly contained schedule, ends or starts non-contained schedules" do
          Given!(:first_schedule) { FactoryGirl.create :schedule, end_date: Date.tomorrow + 3.days }
          Given!(:second_schedule) {FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.tomorrow + 6.days, end_date: Date.tomorrow + 10.days }
          Given!(:third_schedule) {FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.tomorrow + 12.days}
          Given!(:fourth_schedule) {FactoryGirl.create :schedule, user: first_schedule.user, start_date: Date.tomorrow, end_date: Date.tomorrow + 15.days }

          Then { first_schedule.reload.end_date.should eq Date.today }
          And  { expect { second_schedule.reload }.to raise_error(ActiveRecord::RecordNotFound) }
          And  { third_schedule.reload.start_date.should eq (Date.tomorrow + 16.days) }
          And  { third_schedule.reload.end_date.should be_nil }
        end
      end
    end

    describe ".notify_timesheet" do
      Given(:Timesheet) { double 'Timesheet' }
      it "should notify timesheets of a change" do
        Timesheet.should_receive :schedule_changed
        FactoryGirl.create :schedule
      end
    end
  end
end
