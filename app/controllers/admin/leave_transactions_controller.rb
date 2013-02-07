class Admin::LeaveTransactionsController < ApplicationController
  before_filter :authenticate_admin!
  respond_to :html

  def new
    @leave_transaction = LeaveTransaction.new(user_id: params[:user_id], date: Date.today)
    respond_with @leave_transaction
  end

  def create
    @leave_transaction = LeaveTransaction.create(params[:leave_transaction])
    redirect_to admin_profile_path(@leave_transaction.user_id)
  end
end
