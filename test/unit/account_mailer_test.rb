require 'test_helper'
require 'account_mailer'

class AccountMailerTest < ActiveSupport::TestCase
  def test_should_send_signup_notification_if_send_notification_mail_option_is_enabled
    Masquerade::Application::Config['send_activation_mail'] = true
    @account = Account.create valid_account_attributes

    response = AccountMailer.signup_notification(@account)
    assert_equal @account.email, response.to[0]
    assert response.parts.size == 2
    response.parts.each { |part| assert part.body.match(@account.activation_code) }
  end

  def test_should_not_send_signup_notification_if_send_notification_mail_option_is_disabled
    Masquerade::Application::Config['send_activation_mail'] = false
    @account = Account.create valid_account_attributes

    assert_raise RuntimeError, "send_activation_mail deactivated" do
      AccountMailer.signup_notification(@account)
    end
  end

  def test_should_send_forgot_password
    @account = Account.create valid_account_attributes
    @account.forgot_password!
    response = AccountMailer.forgot_password(@account)
    assert_equal @account.email, response.to[0]
    assert response.parts.size == 2
    response.parts.each { |part| assert part.body.match(@account.password_reset_code) }
  end
  
end
