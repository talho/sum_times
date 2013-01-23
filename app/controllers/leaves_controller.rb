class LeavesController < ApplicationController
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
    @leafe = Leave.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @leafe }
    end
  end

  # GET /leaves/new
  # GET /leaves/new.json
  def new
    @leafe = Leave.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @leafe }
    end
  end

  # GET /leaves/1/edit
  def edit
    @leafe = Leave.find(params[:id])
  end

  # POST /leaves
  # POST /leaves.json
  def create
    @leafe = Leave.new(params[:leafe])

    respond_to do |format|
      if @leafe.save
        format.html { redirect_to @leafe, notice: 'Leave was successfully created.' }
        format.json { render json: @leafe, status: :created, location: @leafe }
      else
        format.html { render action: "new" }
        format.json { render json: @leafe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /leaves/1
  # PUT /leaves/1.json
  def update
    @leafe = Leave.find(params[:id])

    respond_to do |format|
      if @leafe.update_attributes(params[:leafe])
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
    @leafe = Leave.find(params[:id])
    @leafe.destroy

    respond_to do |format|
      format.html { redirect_to leaves_url }
      format.json { head :no_content }
    end
  end
end
