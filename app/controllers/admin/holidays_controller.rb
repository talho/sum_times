class Admin::HolidaysController < ApplicationController
  before_filter :authenticate_admin!

  respond_to :html
  # GET /admin/holidays
  # GET /admin/holidays.json
  def index
    @holidays = Holiday.all

    respond_with(@holidays)
  end

  # GET /admin/holidays/new
  # GET /admin/holidays/new.json
  def new
    @holiday = Holiday.new

    respond_with(@holiday)
  end

  # GET /admin/holidays/1/edit
  def edit
    @holiday = Holiday.find(params[:id])

    respond_with(@holiday)
  end

  # POST /admin/holidays
  # POST /admin/holidays.json
  def create
    @holiday = Holiday.new(params[:holiday])

    @holiday.save
    respond_with(@holiday) do |format|
      if @holiday.errors.blank?
        format.all { redirect_to admin_holidays_path }
      else
        format.all { render 'new' }
      end
    end
  end

  # PUT /admin/holidays/1
  # PUT /admin/holidays/1.json
  def update
    @holiday = Holiday.find(params[:id])

    @holiday.update_attributes(params[:holiday])
    respond_with(@holiday) do |format|
      if @holiday.errors.blank?
        format.all { redirect_to admin_holidays_path }
      else
        format.all { render 'edit' }
      end
    end
  end

  # DELETE /admin/holidays/1
  # DELETE /admin/holidays/1.json
  def destroy
    @holiday = Holiday.find(params[:id])
    @holiday.destroy

    respond_with(@holiday) do |format|
      format.all {redirect_to admin_holidays_path}
    end
  end
end
