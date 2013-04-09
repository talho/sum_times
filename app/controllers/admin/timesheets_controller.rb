class Admin::TimesheetsController < ApplicationController
  before_filter :authenticate_admin!
  respond_to :html
  def index
    month = params[:month].to_i unless params[:month].blank?
    year = params[:year].to_i unless params[:year].blank?
    @date = Date.today.at_beginning_of_month.change(:month => month, :year => year )
    @timesheets = Timesheet.where(month: @date.month, year: @date.year)
    respond_with(@timesheets, @date)
  end

  def show
    @timesheet = Timesheet.find(params[:id])

    respond_with(@timesheet)
  end

  def generate
    month = params[:month].blank? ? params[:month] : Date.today.month
    year = params[:year].blank? ? params[:year] : Date.today.year

    User.all.each do |user|
      ts = Timesheet.where(user_id: user.id, month: month, year: year).first_or_create
      unless ts.ready_for_submission
        ts.ready_for_submission = true
        ts.save
      end
    end

    redirect_to admin_timesheets_path(month: params[:month], year: params[:year])
  end
end
