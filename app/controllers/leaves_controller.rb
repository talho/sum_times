class LeavesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  # GET /leaves
  # GET /leaves.json
  def index
    @leaves = Leave.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @leaves }
    end
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
    @leave = Leave.find(params[:id])

    respond_to do |format|
      if @leave.update_attributes(params[:leafe])
        format.html { redirect_to @leafe, notice: 'Leave was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @leafe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leaves/1
  # DELETE /leaves/1.json
  def destroy
    @leave = Leave.find(params[:id])
    @leave.destroy

    if current_user.id = @leave.user_id
      redirect_to edit_profiles_path
    else
      redirect_to leaves_path
    end
  end
end
