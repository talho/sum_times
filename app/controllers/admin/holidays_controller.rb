class Admin::HolidaysController < ApplicationController
  # GET /admin/holidays
  # GET /admin/holidays.json
  def index
    @admin_holidays = Admin::Holiday.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_holidays }
    end
  end

  # GET /admin/holidays/1
  # GET /admin/holidays/1.json
  def show
    @admin_holiday = Admin::Holiday.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_holiday }
    end
  end

  # GET /admin/holidays/new
  # GET /admin/holidays/new.json
  def new
    @admin_holiday = Admin::Holiday.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_holiday }
    end
  end

  # GET /admin/holidays/1/edit
  def edit
    @admin_holiday = Admin::Holiday.find(params[:id])
  end

  # POST /admin/holidays
  # POST /admin/holidays.json
  def create
    @admin_holiday = Admin::Holiday.new(params[:admin_holiday])

    respond_to do |format|
      if @admin_holiday.save
        format.html { redirect_to @admin_holiday, notice: 'Holiday was successfully created.' }
        format.json { render json: @admin_holiday, status: :created, location: @admin_holiday }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/holidays/1
  # PUT /admin/holidays/1.json
  def update
    @admin_holiday = Admin::Holiday.find(params[:id])

    respond_to do |format|
      if @admin_holiday.update_attributes(params[:admin_holiday])
        format.html { redirect_to @admin_holiday, notice: 'Holiday was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/holidays/1
  # DELETE /admin/holidays/1.json
  def destroy
    @admin_holiday = Admin::Holiday.find(params[:id])
    @admin_holiday.destroy

    respond_to do |format|
      format.html { redirect_to admin_holidays_url }
      format.json { head :no_content }
    end
  end
end
