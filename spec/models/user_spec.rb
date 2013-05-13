require 'spec_helper'

describe User do
  it { should have_many(:schedules) }
  it { should have_many(:leaves) }
  it { should have_many(:leave_transactions) }
  it { should have_many(:timesheets) }

  describe '.supervisors & .supervises' do
    Given!(:user) { FactoryGirl.create :user }
    Given!(:user2) { FactoryGirl.create :user }
    Given { user.supervisors << user2 }

    context 'supervisors should be opposite supervises' do
      Then { user.supervisors.should include(user2)}
      And  { user2.supervises.should include(user)}
    end

    describe '.leave_requests' do
      Given!(:leave) { FactoryGirl.create :leave, :vacation, user: user }

      Then { user2.leave_requests.should include(leave) }
    end

    describe '.timesheets_to_accept' do
      Given!(:timesheet) { FactoryGirl.create :timesheet, user: user }

      Then { user2.timesheets_to_accept.should include(timesheet) }
    end
  end

  describe '.current_schedule' do
    Given(:user) { FactoryGirl.create :user }

    context 'should return nil with no schedule' do
      Then { user.current_schedule.should be_nil }
    end

    context 'should return nil when outside of date range' do
      Given { FactoryGirl.create :schedule, user: user, end_date: 2.days.ago }
      Then { user.current_schedule.should be_nil }
    end

    context 'should return only schedule with one schedule' do
      Given!(:schedule) { FactoryGirl.create :schedule, user: user }
      Then { user.current_schedule.should eq schedule }
    end

    context 'should return active schedule with more than one schedule' do
      Given { FactoryGirl.create :schedule, user: user, start_date: 1.month.ago, end_date: 2.days.ago }
      Given!(:schedule) { FactoryGirl.create :schedule, user: user, start_date: 1.day.ago, end_date: 2.days.from_now }
      Given { FactoryGirl.create :schedule, user: user, start_date: 3.days.from_now }

      Then { Schedule.count.should eq 3 }
      Then { user.current_schedule.should eq schedule }
    end
  end

  context 'hours' do
    Given!(:stub) { User.any_instance.stub(:transaction_hours) }
    Given!(:user) { FactoryGirl.create :user }


    describe '.vacation_hours' do
      When { user.should_receive(:transaction_hours).with('vacation') }

      Then { user.vacation_hours }
    end

    describe '.sick_hours' do
      When { user.should_receive(:transaction_hours).with('sick') }

      Then { user.sick_hours }
    end
  end

  describe '.accrues_vacation' do
    context 'accrues_vacation set' do
      Given(:user) { FactoryGirl.create :user, accrues_vacation: 18 }

      Then { user.accrues_vacation.should eq 18 }
    end

    context 'accrues_vacation not set' do
      Given(:user) { FactoryGirl.create :user }

      Then { user.accrues_vacation.should eq 6.67 }
    end
  end

  describe '.accrues_sick' do
    context 'accrues_sick set' do
      Given(:user) { FactoryGirl.create :user, accrues_sick: 18 }

      Then { user.accrues_sick.should eq 18 }
    end

    context 'accrues_sick not set' do
      Given(:user) { FactoryGirl.create :user }

      Then { user.accrues_sick.should eq 8 }
    end
  end

  describe '.transaction_hours' do
    Given(:user) { FactoryGirl.create :user }

    context 'calculates 0 when empty' do
      When(:value) { user.send :transaction_hours, 'sick' }
      Then { value.should eq 0 }
    end

    context 'returns 0 with non-category leaves' do
      Given { FactoryGirl.create :leave_transaction, :vacation, user: user }

      When(:value) { user.send :transaction_hours, 'sick' }
      Then { value.should eq 0 }
    end

    context 'calculates sum with values' do
      Given { FactoryGirl.create :leave_transaction, :vacation, user: user, hours: 40 }
      Given { FactoryGirl.create :leave_transaction, :vacation, user: user, hours: -8 }
      Given { FactoryGirl.create :leave_transaction, :vacation, user: user, hours: -16 }
      Given { FactoryGirl.create :leave_transaction, :sick, user: user, hours: 10 }

      context 'vacation' do
        When(:value) { user.send :transaction_hours, 'vacation' }
        Then { value.should eq 16 }
      end

      context 'sick' do
        When(:value) { user.send :transaction_hours, 'sick' }
        Then { value.should eq 10 }
      end
    end

    context 'can be negative' do
      Given { FactoryGirl.create :leave_transaction, :vacation, user: user, hours: -8 }
      Given { FactoryGirl.create :leave_transaction, :vacation, user: user, hours: -16 }

      When(:value) { user.send :transaction_hours, 'vacation' }
      Then { value.should eq -24 }
    end

    context 'ignores transactions in the future' do
      Given { FactoryGirl.create :leave_transaction, :vacation, user: user, hours: 40 }
      Given { FactoryGirl.create :leave_transaction, :vacation, :date_tomorrow, user: user, hours: -16 }

      When(:value) { user.send :transaction_hours, 'vacation' }
      Then { value.should eq 40 }
    end
  end
end
