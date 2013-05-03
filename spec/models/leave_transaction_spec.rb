require 'spec_helper'

describe LeaveTransaction do
  it { should validate_presence_of(:user_id)}
  it { should validate_presence_of(:date)}
  it { should validate_presence_of(:hours)}
  it { should validate_numericality_of(:hours)}
end
