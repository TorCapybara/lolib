require 'test_helper'

class StatisticControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get hits" do
    get :hits
    assert_response :success
  end

  test "should get downloads" do
    get :downloads
    assert_response :success
  end

  test "should get views" do
    get :views
    assert_response :success
  end

end
