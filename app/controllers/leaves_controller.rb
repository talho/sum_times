class LeavesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_supervisor!, :only => [:update, :destroy]

  respond_to :html
  # GET /leaves
  # GET /leaves.json
  def index
    @leaves = current_user.leave_requests.unapproved
    respond_with(@leaves)
  end

  # GET /leaves/1
  # GET /leaves/1.json
  def show
    @leave = Leave.find(params[:id])

    respond_with(@leave)
  end

  # GET /leaves/new
  # GET /leaves/new.json
  def new
    @leave = Leave.new(user_id: current_user.id)

    respond_with(@leave)
  end

  # POST /leaves
  # POST /leaves.json
  def create
    @leave = Leave.new(params[:leave])
    @leave.save
    respond_with(@leave)
  end

  # PUT /leaves/1
  # PUT /leaves/1.json
  def update
    @leave.update_attributes(params[:leave])
    respond_with(@leave) do |format|
      format.all {redirect_to leaves_path}
    end
  end

  # DELETE /leaves/1
  # DELETE /leaves/1.json
  def destroy
    @leave.destroy

    if request.referrer == leaves_url
      redirect_to leaves_path
    else
      redirect_to edit_profiles_path
    end
  end

  private

  def check_supervisor!
    @leave = Leave.find(params[:id])
    unless @leave.user_id == current_user.id || @leave.user.supervisors.map(&:id).include?(current_user.id)
      flash[:alert] = 'Can only update or delete leave requests if you are the user or a supervisor of the user that made the request'
      redirect_to request.referrer
      return false
    end
  end
end
