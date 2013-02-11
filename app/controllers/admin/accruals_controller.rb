class Admin::AccrualsController < ApplicationController
  before_filter :authenticate_admin!

  respond_to :html

  def index
    respond_with(@accruals = Accrual.all)
  end

  def new
    respond_with(@accrual = Accrual.new)
  end

  def create
    @accrual = Accrual.new(params[:accrual])

    respond_with(@accrual) do |format|
      if @accrual.save
        format.all {redirect_to admin_accruals_path }
      else
        format.all {render 'new'}
      end
    end
  end
end
