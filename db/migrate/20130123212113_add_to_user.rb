class AddToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, :default => ''
    add_column :users, :leave_time, :float
    add_column :users, :sick_time, :float

    create_table :supervisor_users, :id => false do |t|
      t.integer :supervisor_id
      t.integer :user_id
    end
  end
end
