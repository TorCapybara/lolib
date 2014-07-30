require 'test_helper'

class PrivateMessagesControllerTest < ActionController::TestCase
  setup do
    @private_message = private_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:private_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create private_message" do
    assert_difference('PrivateMessage.count') do
      post :create, private_message: { read: @private_message.read, receiver_id: @private_message.receiver_id, reply_id: @private_message.reply_id, sender_id: @private_message.sender_id, subject: @private_message.subject, text: @private_message.text }
    end

    assert_redirected_to private_message_path(assigns(:private_message))
  end

  test "should show private_message" do
    get :show, id: @private_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @private_message
    assert_response :success
  end

  test "should update private_message" do
    patch :update, id: @private_message, private_message: { read: @private_message.read, receiver_id: @private_message.receiver_id, reply_id: @private_message.reply_id, sender_id: @private_message.sender_id, subject: @private_message.subject, text: @private_message.text }
    assert_redirected_to private_message_path(assigns(:private_message))
  end

  test "should destroy private_message" do
    assert_difference('PrivateMessage.count', -1) do
      delete :destroy, id: @private_message
    end

    assert_redirected_to private_messages_path
  end
end
