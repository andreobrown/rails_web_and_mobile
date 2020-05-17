require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
    sign_in customers(:one)
  end

  test "should not be able to access orders if not logged in" do
    sign_out customers(:one)
    get orders_url
    assert_redirected_to new_customer_session_path
  end

  test "should get index" do
    get orders_url
    assert_response :success
  end

  test "should get new" do
    get new_order_url
    assert_response :success
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: { order: { item: @order.item, quantity: @order.quantity, status: @order.status } }
    end

    assert_redirected_to order_url(Order.last)
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), params: { order: { item: @order.item, quantity: @order.quantity, status: @order.status } }
    assert_redirected_to order_url(@order)
  end

  test "should destroy order" do
    assert_difference("Order.count", -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end

  test "should not be able to access orders of another customer" do
    sign_out customers(:one)
    sign_in customers(:two)
    get order_url(orders(:one))
    assert_redirected_to orders_url
  end
end
