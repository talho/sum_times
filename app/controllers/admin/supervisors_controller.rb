class Admin::SupervisorsController < ApplicationController
  # GET /admin/supervisors
  # GET /admin/supervisors.json
  def index
    @admin_supervisors = Admin::Supervisor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_supervisors }
    end
  end

  # GET /admin/supervisors/1
  # GET /admin/supervisors/1.json
  def show
    @admin_supervisor = Admin::Supervisor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_supervisor }
    end
  end

  # GET /admin/supervisors/new
  # GET /admin/supervisors/new.json
  def new
    @admin_supervisor = Admin::Supervisor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_supervisor }
    end
  end

  # GET /admin/supervisors/1/edit
  def edit
    @admin_supervisor = Admin::Supervisor.find(params[:id])
  end

  # POST /admin/supervisors
  # POST /admin/supervisors.json
  def create
    @admin_supervisor = Admin::Supervisor.new(params[:admin_supervisor])

    respond_to do |format|
      if @admin_supervisor.save
        format.html { redirect_to @admin_supervisor, notice: 'Supervisor was successfully created.' }
        format.json { render json: @admin_supervisor, status: :created, location: @admin_supervisor }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_supervisor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/supervisors/1
  # PUT /admin/supervisors/1.json
  def update
    @admin_supervisor = Admin::Supervisor.find(params[:id])

    respond_to do |format|
      if @admin_supervisor.update_attributes(params[:admin_supervisor])
        format.html { redirect_to @admin_supervisor, notice: 'Supervisor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_supervisor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/supervisors/1
  # DELETE /admin/supervisors/1.json
  def destroy
    @admin_supervisor = Admin::Supervisor.find(params[:id])
    @admin_supervisor.destroy

    respond_to do |format|
      format.html { redirect_to admin_supervisors_url }
      format.json { head :no_content }
    end
  end
end
