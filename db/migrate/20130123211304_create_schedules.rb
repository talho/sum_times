class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :user_id
      t.string :days
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
