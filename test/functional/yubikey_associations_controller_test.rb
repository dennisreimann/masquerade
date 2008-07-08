require File.dirname(__FILE__) + '/../test_helper'

class YubikeyAssociationsControllerTest < ActionController::TestCase
  
  fixtures :accounts
  
  def test_should_associate_an_account_with_the_given_yubikey
    @account = accounts(:standard)
    login_as(:standard)
    yubico_otp = 'x' * 44
    Account.expects(:verify_yubico_otp).with(yubico_otp).returns(true)
    post :create, :yubico_otp => yubico_otp
    @account.reload
    assert_equal 'x' * 12, @account.yubico_identity
    assert_redirected_to edit_account_url
  end
  
  def test_should_remove_an_association
    @account = accounts(:with_yubico_identity)
    login_as(:with_yubico_identity)
    delete :destroy
    @account.reload
    assert_nil @account.yubico_identity
    assert_redirected_to edit_account_url
  end
end
