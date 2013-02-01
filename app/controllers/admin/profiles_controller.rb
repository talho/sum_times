class Admin::ProfilesController < ApplicationController
  before_filter :authenticate_admin!

  respond_to :html

  # GET /admin/profiles
  # GET /admin/profiles.json
  def index
    @users = User.all

    respond_with @users
  end

  # GET /admin/profiles/1
  # GET /admin/profiles/1.json
  def show
    @user = User.find(params[:id])

    respond_with @user
  end

  # GET /admin/profiles/new
  # GET /admin/profiles/new.json
  def new
    @user = User.new

    respond_with @user
  end

  # GET /admin/profiles/1/edit
  def edit
    @user = User.find(params[:id])

    respond_with @user
  end

  # POST /admin/profiles
  # POST /admin/profiles.json
  def create
    @user = User.new(params[:user])

    @user.save
    respond_with @user do |format|
      if @user.errors.blank?
        format.all {redirect_to admin_profile_path(@user.id)}
      else
        format.all {render 'new'}
      end
    end
  end

  # PUT /admin/profiles/1
  # PUT /admin/profiles/1.json
  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?
    @user = User.find(params[:id])

    @user.update_attributes params[:user]
    respond_with @user do |format|
      if @user.errors.blank?
        format.all {redirect_to admin_profile_path(@user.id)}
      else
        format.all {render 'edit'}
      end
    end
  end

  # DELETE /admin/profiles/1
  # DELETE /admin/profiles/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to admin_profiles_path
  end
end
