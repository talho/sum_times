class TimesheetsController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!

  def index
    @timesheets = current_user.timesheets_to_accept.waiting_for_supervisor
    respond_with(@timesheets)
  end

  def show
    @timesheet = current_user.timesheets.where(id: params[:id]).first
    unless @timesheet
      @timesheet = current_user.timesheets_to_accept.where(id: params[:id]).first
      @is_supervisor = @timesheet.present?
    end

    respond_with(@timesheet, @is_supervisor)
  end

  def update
    # user can update the timesheet to change the hours worked. recalculate the total hours worked and the total hours server side
    @timesheet = current_user.timesheets.where(id: params[:id]).first

    schedule = @timesheet.schedule

    params[:schedule].each do |day, v|

    end

    respond_with(@timesheet) do |format|
      format.any { render :nothing => true}
    end
  end

  def submit
    @timesheet = current_user.timesheets.find(params[:id])
    @timesheet.update_attributes user_approved: true

    redirect_to timesheet_path(@timesheet)
  end

  def accept
    @timesheet = current_user.timesheets_to_accept.find(params[:id])
    @timesheet.update_attributes supervisor_approved: true

    redirect_to timesheet_path(@timesheet)
  end

  def reject
    @timesheet = current_user.timesheets_to_accept.find(params[:id])
    @timesheet.update_attributes user_approved: nil

    redirect_to timesheet_path(@timesheet)
  end

  def regenerate
    @timesheet = current_user.timesheets.find(params[:id])

    if @timesheet
      @timesheet.generate_schedule
      @timesheet.save
    end

    redirect_to timesheet_path(@timesheet)
  end
end
