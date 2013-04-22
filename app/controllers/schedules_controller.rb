class SchedulesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  # GET /schedules
  # GET /schedules.json
  def index
    @lates = Late.where(date: Date.today)
    @leaves = Leave.where("(start_date <= :date AND end_date >= :date) or start_date = :date", date: Date.today)
    @schedules = Schedule.over_dates(Date.today, Date.today)
    @schedules = @schedules.where("user_id NOT IN (?)", @leaves.select("user_id").where("hours IS NULL OR hours >=8").group(:user_id).map(&:user_id)) unless @leaves.blank?
    @holidays = Holiday.where("(start_date <= :date AND end_date >= :date) OR start_date = :date", date: Date.today)

    respond_with(@schedules, @lates, @leaves, @holidays)
  end

  def calendar
    month = params[:month].to_i unless params[:month].blank?
    year = params[:year].to_i unless params[:year].blank?
    @date = Date.today.at_beginning_of_month.change(:month => month, :year => year )

    @lates = Late.where(date: Date.today) if @date.month == Date.today.month

    @daily_schedules = DailySchedule.new
    add_user_schedules(Schedule.over_dates(@date.at_beginning_of_month, @date.at_end_of_month))
    add_to_schedules(Holiday.where(''), :holidays)
    add_to_schedules(Leave.where(''), :leaves)

    respond_with(@daily_schedules, @date)
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
    # Ok so this kinda breaks, well, everything, but the id passed in is the user that we want to see, not the schedule.
    month = params[:month].to_i unless params[:month].blank?
    year = params[:year].to_i unless params[:year].blank?
    @date = Date.today.at_beginning_of_month.change(:month => month, :year => year )

    @lates = Late.where(user_id: current_user.id, date: Date.today) if @date.month == Date.today.month

    @daily_schedules = DailySchedule.new
    add_user_schedules(Schedule.over_dates(@date.at_beginning_of_month, @date.at_end_of_month).where(user_id: params[:id]))
    add_to_schedules(Holiday.where(''), :holidays)
    add_to_schedules(Leave.where(user_id: current_user.id), :leaves)

    respond_with(@daily_schedules, @date, @lates)
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

  def destroy
    @schedule = Schedule.where(user_id: current_user.id, id: params[:id]).first
    if @schedule && @schedule.destroy
      respond_with(@schedule) do |format|
        format.html {render :nothing => true}
      end
    else
      respond_with(@schedule)
    end
  end

  private

  def add_user_schedules(schedules)
    schedules = schedules.includes(:user)

    schedules.each do |sched|
      @daily_schedules[sched.date][:schedules] << sched if sched.hours > 0
    end
  end

  def add_to_schedules(rel, sym)
    rel = rel.where("(start_date >= :start AND start_date <= :end) OR (end_date >= :start AND end_date <= :end)", start: @date.at_beginning_of_month, end: @date.at_end_of_month)
    rel.each do |item|
      if item.end_date.nil?
        @daily_schedules[item.start_date][sym] << item
      else
        i = [item.start_date, @date.at_beginning_of_month].max
        while i <= item.end_date && i <= @date.at_end_of_month
          @daily_schedules[i][sym] << item
          i += 1.day
        end
      end
    end
  end
end
