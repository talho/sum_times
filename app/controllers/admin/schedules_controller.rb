class Admin::SchedulesController < ApplicationController
  before_filter :authenticate_admin!

  respond_to :html

  def new
    @schedule = Schedule.new(user_id: params[:user_id], start_date: Date.today)

    respond_with(@schedule)
  end

  def create
    @schedule = Schedule.new(params[:schedule])
    @schedule.days = params[:days]

    if @schedule.save
      redirect_to admin_profile_path(@schedule.user_id)
    else
      respond_with(@schedule) do
        format.html {render 'new'}
      end
    end
  end

  def edit
    @schedule = Schedule.where(id: params[:id]).first

    respond_with(@schedule)
  end

  def update
    @schedule = Schedule.where(id: params[:id]).first
    @schedule.attributes = params[:schedule]
    @schedule.days = params[:days]

    if @schedule.save
      redirect_to admin_profile_path(@schedule.user_id)
    else
      respond_with(@schedule) do
        format.html {render 'edit'}
      end
    end
  end

  def destroy
    @schedule = Schedule.where(id: params[:id]).first
    if @schedule && @schedule.destroy
      respond_with(@schedule) do |format|
        format.html {render :nothing => true}
      end
    else
      respond_with(@schedule)
    end
  end
end
