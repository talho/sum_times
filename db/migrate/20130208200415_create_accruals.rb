class CreateAccruals < ActiveRecord::Migration
  def change
    create_table :accruals do |t|
      t.integer :month
      t.integer :year

      t.timestamps
    end

    add_column :users, :accrues_vacation, :float
    add_column :users, :accrues_sick, :float
  end
end
