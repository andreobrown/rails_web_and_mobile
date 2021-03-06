require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  setup do
    @customer = customers(:one)
  end

  test "visiting the login page" do
    visit new_customer_registration_url
    assert_selector "h2", text: "Sign up"
    assert_selector "a", text: "Login"
  end

  test "sign up a Customer" do
    visit new_customer_registration_url

    fill_in "Email", with: "newtest@example.com"
    fill_in "Password", with: "@insecure"
    fill_in "Password confirmation", with: "@insecure"
    click_on "Sign up"

    assert_text "Welcome! You have signed up successfully."
  end

  test "sign in a Customer" do
    visit new_customer_session_url

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "@insecure"
    click_on "Log in"
  end
end
