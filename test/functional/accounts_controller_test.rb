require File.dirname(__FILE__) + '/../test_helper'

class AccountsControllerTest < ActionController::TestCase
  
  fixtures :accounts
  
  def test_should_allow_signup
    assert_difference 'Account.count' do
      post :create, :account => valid_account_attributes
    end  
    assert_redirected_to login_path
  end

  def test_should_require_login_for_edit
    get :edit
    assert_login_required
  end

  def test_should_require_login_for_update
    put :update
    assert_login_required
  end
  
  def test_should_require_login_for_destroy
    delete :destroy
    assert_login_required
  end
  
  def test_should_require_login_for_change_password
    put :change_password
    assert_login_required
  end
  
  def test_should_disable_account_if_confirmation_password_matches
    login_as(:standard)
    delete :destroy, :confirmation_password => 'test'
    assert !accounts(:standard).reload.enabled
    assert_redirected_to home_url
  end
  
  def test_should_not_disable_account_if_confirmation_password_does_not_match
    login_as(:standard)
    delete :destroy, :confirmation_password => 'lksdajflsaf'
    assert accounts(:standard).reload.enabled
    assert_redirected_to edit_account_url
  end
  
  def test_should_set_yadis_header_on_identity_page
    account = accounts(:standard).login
    get :show, :account => account
    assert_match identity_url(account, :format => :xrds), @response.headers['X-XRDS-Location']
  end
  
end
