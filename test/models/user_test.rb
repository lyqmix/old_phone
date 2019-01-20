require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "user model" do
	user=User.new
	user.name="zhansgsa"
	user.password="1234555"
	user.phone="13466546933"
	user.email="2765089665@qq.com"
	assert user.vaild?
  end
end
