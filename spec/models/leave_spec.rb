require 'spec_helper'

describe Leave do
  it { should belong_to :user}

  it "should initialize date_hours instance variable" do
    leave = Leave.new
    leave.instance_variable_get('@date_hours').should eq({})
  end

  describe ".hours" do
    it "should return hours if they were set" do
      @leave = FactoryGirl.build(:leave, hours: 5)
      @leave.hours.should eq 5
    end

    context "hours not specified" do
      before :each do
        @schedule = FactoryGirl.create(:schedule)
        @leave = FactoryGirl.build(:leave, :with_end_date, user: @schedule.user)
      end

      it "should return total hours from schedule" do
        @leave.hours.should eq 16 # bit of magic-numbering here, but schedule is created with 8 hour days, 7 days/week (NO WEEKENDS FOR YOU)
      end

      it "should should return hours on a specific date" do
        @leave.hours(1.day.from_now.to_date).should eq 8
      end
    end

  end

  context "after update" do
    before :each do
      @leave = FactoryGirl.create(:leave, :with_hours)
    end

    it "should create the leave transaction if the leave was approved" do
      expect {
        @leave.update_attributes approved: true
      }.to change(LeaveTransaction, :count).by 1
    end

    it "should set the expected leave transaction days and hours" do
      @leave.update_attributes approved: true
      LeaveTransaction.last.as_json(:only => [:hours, :date]).should eq({date: 1.day.from_now.to_date, hours: -4.0}.with_indifferent_access)
    end
  end

  context "after save" do
    Given(:Timesheet) { double 'Timesheet' }

    it "should notify any active timesheets so they update" do
      @schedule = FactoryGirl.create(:schedule)
      Timesheet.should_receive :leave_added
      @leave = FactoryGirl.create(:leave, :vacation, :with_end_date, user: @schedule.user)
    end
  end
end
