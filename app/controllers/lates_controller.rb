class LatesController < ApplicationController
  # GET /lates
  # GET /lates.json
  def index
    @lates = Late.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lates }
    end
  end

  # GET /lates/1
  # GET /lates/1.json
  def show
    @late = Late.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @late }
    end
  end

  # GET /lates/new
  # GET /lates/new.json
  def new
    @late = Late.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @late }
    end
  end

  # GET /lates/1/edit
  def edit
    @late = Late.find(params[:id])
  end

  # POST /lates
  # POST /lates.json
  def create
    @late = Late.new(params[:late])

    respond_to do |format|
      if @late.save
        format.html { redirect_to @late, notice: 'Late was successfully created.' }
        format.json { render json: @late, status: :created, location: @late }
      else
        format.html { render action: "new" }
        format.json { render json: @late.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lates/1
  # PUT /lates/1.json
  def update
    @late = Late.find(params[:id])

    respond_to do |format|
      if @late.update_attributes(params[:late])
        format.html { redirect_to @late, notice: 'Late was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @late.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lates/1
  # DELETE /lates/1.json
  def destroy
    @late = Late.find(params[:id])
    @late.destroy

    respond_to do |format|
      format.html { redirect_to lates_url }
      format.json { head :no_content }
    end
  end
end
