require "test_helper"

class SalesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get sales_edit_url
    assert_response :success
  end

  test "should get update" do
    get sales_update_url
    assert_response :success
  end

  test "should get destroy" do
    get sales_destroy_url
    assert_response :success
  end
end
