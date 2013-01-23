require 'test_helper'

class Admin::HolidaysControllerTest < ActionController::TestCase
  setup do
    @admin_holiday = admin_holidays(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_holidays)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_holiday" do
    assert_difference('Admin::Holiday.count') do
      post :create, admin_holiday: {  }
    end

    assert_redirected_to admin_holiday_path(assigns(:admin_holiday))
  end

  test "should show admin_holiday" do
    get :show, id: @admin_holiday
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_holiday
    assert_response :success
  end

  test "should update admin_holiday" do
    put :update, id: @admin_holiday, admin_holiday: {  }
    assert_redirected_to admin_holiday_path(assigns(:admin_holiday))
  end

  test "should destroy admin_holiday" do
    assert_difference('Admin::Holiday.count', -1) do
      delete :destroy, id: @admin_holiday
    end

    assert_redirected_to admin_holidays_path
  end
end
