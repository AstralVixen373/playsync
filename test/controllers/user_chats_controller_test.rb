require "test_helper"

class UserChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get user_chats_create_url
    assert_response :success
  end

  test "should get destroy" do
    get user_chats_destroy_url
    assert_response :success
  end
end
