require 'test_helper'
require 'account_mailer'

class AccountMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    @account = Account.create valid_account_attributes
  end
  
  def test_should_send_signup_notification
    response = AccountMailer.signup_notification(@account)
    assert_equal @account.email, response.to[0]
    assert response.body.include?(@account.activation_code)
  end
  
  def test_should_send_forgot_password
    @account.forgot_password!
    response = AccountMailer.forgot_password(@account)
    assert_equal @account.email, response.to[0]
    assert response.body.include?(@account.password_reset_code)
  end
  
end
