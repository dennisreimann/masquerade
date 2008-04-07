require File.dirname(__FILE__) + '/../test_helper'
require 'account_mailer'

class AccountMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @account = Account.create valid_account_attributes
    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end
  
  def test_should_send_signup_notification
    response = AccountMailer.create_signup_notification(@account)
    assert_equal @account.email, response.to[0]
    assert_match @account.activation_code, response.body
  end
  
  def test_should_send_forgot_password
    @account.forgot_password!
    response = AccountMailer.create_forgot_password(@account)
    assert_equal @account.email, response.to[0]
    assert_match @account.password_reset_code, response.body
  end
  
end
