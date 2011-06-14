require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  
  fixtures :accounts
  
  def test_should_allow_signup
    assert_difference 'Account.count' do
      post :create, :account => valid_account_attributes
    end  
    assert_redirected_to login_path
  end

  def test_should_show_correct_message_after_signup_if_send_activation_mail_is_disabled
    Masquerade::Application::Config['disable_registration'] = false # doesn't make sense if registration is disabled
    Masquerade::Application::Config['send_activation_mail'] = true
    post :create, :account => valid_account_attributes
    assert_equal I18n.t(:thanks_for_signing_up_activation_link), flash[:notice]
  end

  def test_should_show_correct_message_after_signup_if_send_activation_mail_is_enabled
    Masquerade::Application::Config['disable_registration'] = false # doesn't make sense if registration is disabled
    Masquerade::Application::Config['send_activation_mail'] = false
    post :create, :account => valid_account_attributes
    assert_equal I18n.t(:thanks_for_signing_up), flash[:notice]
  end

  def test_should_allow_activate_if_send_activation_mail_is_enabled
    Masquerade::Application::Config['send_activation_mail'] = true
    get :activate, :account => valid_account_attributes
    assert_response :found
  end

  def test_should_return404_activate_if_send_activation_mail_is_disabled
    Masquerade::Application::Config['send_activation_mail'] = false
    get :activate, :account => valid_account_attributes
    assert_response :not_found
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
  
  def test_should_disable_account_if_confirmation_password_matches_and_can_disable_account_is_enabled
    Masquerade::Application::Config['can_disable_account'] = true
    login_as(:standard)
    delete :destroy, :confirmation_password => 'test'
    assert !accounts(:standard).reload.enabled
    assert_redirected_to root_url
  end

  def test_should_get_404_on_disable_account_if_confirmation_password_matches_and_can_disable_account_is_disabled
    Masquerade::Application::Config['can_disable_account'] = false
    login_as(:standard)
    delete :destroy, :confirmation_password => 'test'
    assert_response :not_found
  end
  
  def test_should_not_disable_account_if_confirmation_password_does_not_match
    Masquerade::Application::Config['can_disable_account'] = true # doesn't make sense if registration is disabled
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
