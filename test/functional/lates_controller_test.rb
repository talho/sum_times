require 'test_helper'

class LatesControllerTest < ActionController::TestCase
  setup do
    @late = lates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create late" do
    assert_difference('Late.count') do
      post :create, late: {  }
    end

    assert_redirected_to late_path(assigns(:late))
  end

  test "should show late" do
    get :show, id: @late
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @late
    assert_response :success
  end

  test "should update late" do
    put :update, id: @late, late: {  }
    assert_redirected_to late_path(assigns(:late))
  end

  test "should destroy late" do
    assert_difference('Late.count', -1) do
      delete :destroy, id: @late
    end

    assert_redirected_to lates_path
  end
end
