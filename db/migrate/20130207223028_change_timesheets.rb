class ChangeTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :total_hours, :float
    add_column :timesheets, :worked_hours, :float
    add_column :timesheets, :holiday_hours, :float
    add_column :timesheets, :vacation_hours, :float
    add_column :timesheets, :sick_hours, :float
    add_column :timesheets, :admin_hours, :float
    add_column :timesheets, :unpaid_hours, :float
  end
end
