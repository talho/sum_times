class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  # attr_accessible :title, :body

  has_and_belongs_to_many :supervisors, :association_foreign_key => :supervisor_id, :class_name => "User", :join_table => 'supervisor_users'
  has_and_belongs_to_many :supervises, :foreign_key => :supervisor_id, :class_name => "User", :join_table => 'supervisor_users'

  has_many :schedules
  has_many :leaves

  def current_schedule
    self.schedules.where('start_date <= :date AND (end_date > :date OR end_date IS NULL)', :date => Date.today).first
  end

  def future_schedules
    self.schedules.where('start_date > :date', :date => Date.today)
  end
end
