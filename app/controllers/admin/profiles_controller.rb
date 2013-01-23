class Admin::ProfilesController < ApplicationController
  # GET /admin/profiles
  # GET /admin/profiles.json
  def index
    @admin_profiles = Admin::Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_profiles }
    end
  end

  # GET /admin/profiles/1
  # GET /admin/profiles/1.json
  def show
    @admin_profile = Admin::Profile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_profile }
    end
  end

  # GET /admin/profiles/new
  # GET /admin/profiles/new.json
  def new
    @admin_profile = Admin::Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_profile }
    end
  end

  # GET /admin/profiles/1/edit
  def edit
    @admin_profile = Admin::Profile.find(params[:id])
  end

  # POST /admin/profiles
  # POST /admin/profiles.json
  def create
    @admin_profile = Admin::Profile.new(params[:admin_profile])

    respond_to do |format|
      if @admin_profile.save
        format.html { redirect_to @admin_profile, notice: 'Profile was successfully created.' }
        format.json { render json: @admin_profile, status: :created, location: @admin_profile }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/profiles/1
  # PUT /admin/profiles/1.json
  def update
    @admin_profile = Admin::Profile.find(params[:id])

    respond_to do |format|
      if @admin_profile.update_attributes(params[:admin_profile])
        format.html { redirect_to @admin_profile, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/profiles/1
  # DELETE /admin/profiles/1.json
  def destroy
    @admin_profile = Admin::Profile.find(params[:id])
    @admin_profile.destroy

    respond_to do |format|
      format.html { redirect_to admin_profiles_url }
      format.json { head :no_content }
    end
  end
end
