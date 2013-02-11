# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130208200415) do

  create_table "accruals", :force => true do |t|
    t.integer  "month"
    t.integer  "year"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "holidays", :force => true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lates", :force => true do |t|
    t.integer  "user_id"
    t.text     "reason"
    t.date     "date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "leave_transactions", :force => true do |t|
    t.integer  "user_id"
    t.string   "category"
    t.float    "hours"
    t.date     "date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "leaves", :force => true do |t|
    t.integer  "user_id"
    t.text     "reason"
    t.integer  "hours"
    t.string   "category"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "approved"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "schedules", :force => true do |t|
    t.integer  "user_id"
    t.text     "days"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "supervisor_users", :id => false, :force => true do |t|
    t.integer "supervisor_id"
    t.integer "user_id"
  end

  create_table "timesheets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "month"
    t.integer  "supervisor_id"
    t.date     "approval_date"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "user_approved"
    t.boolean  "supervisor_approved"
    t.text     "schedule"
    t.integer  "year"
    t.float    "total_hours"
    t.float    "worked_hours"
    t.float    "holiday_hours"
    t.float    "vacation_hours"
    t.float    "sick_hours"
    t.float    "admin_hours"
    t.float    "unpaid_hours"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name",                   :default => ""
    t.float    "leave_time"
    t.float    "sick_time"
    t.float    "accrues_vacation"
    t.float    "accrues_sick"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
