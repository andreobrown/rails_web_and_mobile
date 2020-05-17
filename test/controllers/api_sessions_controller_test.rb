require "test_helper"

class Api::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get token" do
    post new_api_customer_session_url, params: { "api_customer": { "email": "test@example.com", "password": "insecure@" } }, as: :json
    assert_response :success
    assert_includes @response.body, "jwt"
    refute_nil @response.parsed_body["jwt"]
  end
end
