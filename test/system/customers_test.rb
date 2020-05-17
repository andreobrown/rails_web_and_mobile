require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  setup do
    @customer = customers(:one)
  end

  test "visiting the login page" do
    visit new_customer_registration_url
    assert_selector "h2", text: "Sign up"
  end

  test "sign up a Customer" do
    visit new_customer_registration_url

    fill_in "Email", with: "newtest@example.com"
    fill_in "Password", with: "@insecure"
    fill_in "Password confirmation", with: "@insecure"
    click_on "Sign up"
  end
end
