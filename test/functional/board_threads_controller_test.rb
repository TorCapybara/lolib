require 'test_helper'

class BoardThreadsControllerTest < ActionController::TestCase
  setup do
    @board_thread = board_threads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:board_threads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create board_thread" do
    assert_difference('BoardThread.count') do
      post :create, :board_thread => { :name_space_id => @board_thread.name_space_id, :title => @board_thread.title }
    end

    assert_redirected_to board_thread_path(assigns(:board_thread))
  end

  test "should show board_thread" do
    get :show, :id => @board_thread
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @board_thread
    assert_response :success
  end

  test "should update board_thread" do
    put :update, :id => @board_thread, :board_thread => { :name_space_id => @board_thread.name_space_id, :title => @board_thread.title }
    assert_redirected_to board_thread_path(assigns(:board_thread))
  end

  test "should destroy board_thread" do
    assert_difference('BoardThread.count', -1) do
      delete :destroy, :id => @board_thread
    end

    assert_redirected_to board_threads_path
  end
end
