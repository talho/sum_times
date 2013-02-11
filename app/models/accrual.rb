class Accrual < ActiveRecord::Base
  attr_accessible :month, :year

  validates :month, :uniqueness => [:scope => :year]

  before_create :add_times_to_users

  private
  def add_times_to_users
    User.all.each do |user|
      LeaveTransaction.create user_id: user.id, date: Date.today.at_beginning_of_month.change(:month => self.month, :year => self.year), category: 'vacation', hours: user.accrues_vacation
      LeaveTransaction.create user_id: user.id, date: Date.today.at_beginning_of_month.change(:month => self.month, :year => self.year), category: 'sick', hours: user.accrues_sick
    end
  end
end
