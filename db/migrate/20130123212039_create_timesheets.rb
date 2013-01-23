class CreateTimesheets < ActiveRecord::Migration
  def change
    create_table :timesheets do |t|
      t.integer :user_id
      t.integer :month
      t.integer :supervisor_id
      t.date :approval_date

      t.timestamps
    end
  end
end
