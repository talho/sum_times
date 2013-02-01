class Admin::SupervisorsController < ApplicationController
  before_filter :authenticate_admin!

  respond_to :html

  # GET /admin/supervisors
  # GET /admin/supervisors.json
  def index
    @users = User.all

    respond_with(@users)
  end

  # GET /admin/supervisors/1/edit
  def edit
    @user = User.find(params[:id])
    @supervisors = User.where("id != ?", params[:id])
    @supervisors = @supervisors.where("id NOT IN (?)", @user.supervisors) unless @user.supervisors.blank?

    respond_with(@user, @supervisors)
  end

  # PUT /admin/supervisors/1
  # PUT /admin/supervisors/1.json
  def update
    @user = User.find(params[:id])
    User.where(id: params[:user][:supervisors]).each do |supervisor|
      @user.supervisors << supervisor
    end

    respond_with @user do |format|
      format.all {redirect_to admin_profile_path(@user.id)}
    end
  end

  # DELETE /admin/supervisors/1
  # DELETE /admin/supervisors/1.json
  def destroy
    @user = User.find(params[:id])
    @supervisor = User.find(params[:supervisor_id])
    @user.supervisors.delete(@supervisor)

    respond_with @user do |format|
      format.all {redirect_to admin_profile_path(@user.id)}
    end
  end
end
