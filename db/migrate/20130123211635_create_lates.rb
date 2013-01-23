class CreateLates < ActiveRecord::Migration
  def change
    create_table :lates do |t|
      t.integer :user_id
      t.text :reason
      t.date :date

      t.timestamps
    end
  end
end
