require 'spec_helper'

describe Accrual do
  it {should validate_presence_of(:month)}
  it {should validate_presence_of(:year)}
  it {should validate_uniqueness_of(:month).scoped_to(:year)}

  context "before creation" do
    describe ".add_times_to_users" do
      before :each do
        FactoryGirl.create(:user)
        @accrual = FactoryGirl.build(:accrual)
      end

      it "adds vacation time to users" do
        expect {
          @accrual.save
        }.to change{ LeaveTransaction.where(category: 'vacation').count }.by(1)
      end

      it "adds sick time to users" do
        expect {
          @accrual.save
        }.to change{ LeaveTransaction.where(category: 'sick').count }.by(1)
      end
    end
  end
end
