require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "order model" do
	order=Order.new
	order.name="zhangsan"
	order.address="beijing"
	order.email="public@123.com"
	order.pay_type="支付宝"
	assert order.valid?
  end
end
