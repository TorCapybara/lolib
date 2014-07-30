require 'test_helper'

class NameSpacesControllerTest < ActionController::TestCase
  setup do
    @name_space = name_spaces(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:name_spaces)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create name_space" do
    assert_difference('NameSpace.count') do
      post :create, :name_space => { :name => @name_space.name, :parent_id => @name_space.parent_id }
    end

    assert_redirected_to name_space_path(assigns(:name_space))
  end

  test "should show name_space" do
    get :show, :id => @name_space
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @name_space
    assert_response :success
  end

  test "should update name_space" do
    put :update, :id => @name_space, :name_space => { :name => @name_space.name, :parent_id => @name_space.parent_id }
    assert_redirected_to name_space_path(assigns(:name_space))
  end

  test "should destroy name_space" do
    assert_difference('NameSpace.count', -1) do
      delete :destroy, :id => @name_space
    end

    assert_redirected_to name_spaces_path
  end
end
