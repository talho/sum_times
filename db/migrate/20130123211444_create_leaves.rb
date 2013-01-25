class CreateLeaves < ActiveRecord::Migration
  def change
    create_table :leaves do |t|
      t.integer :user_id
      t.text :reason
      t.integer :hours
      t.string :type # ex: vacation, sick
      t.date :start_date
      t.date :end_date
      t.boolean :approved

      t.timestamps
    end
  end
end
