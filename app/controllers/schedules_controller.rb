class SchedulesController < ApplicationController
  respond_to :html
  # GET /schedules
  # GET /schedules.json
  def index
    @schedules = Schedule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schedules }
    end
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.json
  def new
    @schedule = Schedule.new(user_id: current_user.id, start_date: Date.today)

    respond_with(@schedule)
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = Schedule.new(params[:schedule])
    @schedule.days = params[:days]

    if @schedule.save
      redirect_to edit_profiles_path
    else
      respond_with(@schedule) do
        format.html {render 'new'}
      end
    end
  end
end
