require "application_system_test_case"

class PagesTest < ApplicationSystemTestCase
  test "visiting the root page" do
    visit root_url
    assert_selector "p", text: "Place orders with your local cornerstore"
  end

  test "visiting the Home page" do
    visit pages_home_url
    assert_selector "p", text: "Place orders with your local cornerstore"
  end

  test "visiting the About page" do
    visit pages_about_url
    assert_selector "p", text: "We are your local cornerstore"
  end
end
