require 'test_helper'

class TimesheetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get submit" do
    get :submit
    assert_response :success
  end

  test "should get accept" do
    get :accept
    assert_response :success
  end

  test "should get reject" do
    get :reject
    assert_response :success
  end

  test "should get regenerate" do
    get :regenerate
    assert_response :success
  end

end
