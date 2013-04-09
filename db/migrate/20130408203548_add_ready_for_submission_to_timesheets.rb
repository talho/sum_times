class AddReadyForSubmissionToTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :ready_for_submission, :boolean
  end
end
