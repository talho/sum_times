require 'test_helper'

class Admin::SupervisorsControllerTest < ActionController::TestCase
  setup do
    @admin_supervisor = admin_supervisors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_supervisors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_supervisor" do
    assert_difference('Admin::Supervisor.count') do
      post :create, admin_supervisor: {  }
    end

    assert_redirected_to admin_supervisor_path(assigns(:admin_supervisor))
  end

  test "should show admin_supervisor" do
    get :show, id: @admin_supervisor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_supervisor
    assert_response :success
  end

  test "should update admin_supervisor" do
    put :update, id: @admin_supervisor, admin_supervisor: {  }
    assert_redirected_to admin_supervisor_path(assigns(:admin_supervisor))
  end

  test "should destroy admin_supervisor" do
    assert_difference('Admin::Supervisor.count', -1) do
      delete :destroy, id: @admin_supervisor
    end

    assert_redirected_to admin_supervisors_path
  end
end
