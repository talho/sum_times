class CreateLeaveTransactions < ActiveRecord::Migration
  def change
    create_table :leave_transactions do |t|
      t.integer :user_id
      t.string :category
      t.float :hours
      t.date :date

      t.timestamps
    end
  end
end
