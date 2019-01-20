require 'test_helper'

class PhoneTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "phone model" do
	phone=Phone.new
	phone.name="xiaomi"
	phone.brand="xiaomi"
	phone.intro="xiaomi"
	phone.avatar="123.jpg"
	phone.price=1234
	assert phone.valid?
  end
end
