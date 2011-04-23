require 'test_helper'
require 'account_mailer'

class AccountMailerTest < ActiveSupport::TestCase
  
  def setup
    @account = Account.create valid_account_attributes
  end
  
  def test_should_send_signup_notification
    response = AccountMailer.signup_notification(@account)
    assert_equal @account.email, response.to[0]
    assert response.parts.size == 2
    response.parts.each { |part| assert part.body.match(@account.activation_code) }
  end
  
  def test_should_send_forgot_password
    @account.forgot_password!
    response = AccountMailer.forgot_password(@account)
    assert_equal @account.email, response.to[0]
    assert response.parts.size == 2
    response.parts.each { |part| assert part.body.match(@account.password_reset_code) }
  end
  
end
