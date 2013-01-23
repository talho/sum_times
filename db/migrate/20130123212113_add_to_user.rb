class AddToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :name
    end

    create_table :supervisor_users, :id => false do |t|
      t.integer :supervisor_id
      t.integer :user_id
    end
  end
end
