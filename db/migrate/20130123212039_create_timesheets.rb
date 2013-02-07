class CreateTimesheets < ActiveRecord::Migration
  def change
    create_table :timesheets do |t|
      t.integer :user_id
      t.integer :month
      t.integer :year
      t.boolean :user_approved
      t.boolean :supervisor_approved
      t.text :schedule

      t.timestamps
    end
  end
end
