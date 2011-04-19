require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  
  fixtures :accounts
  
  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_display_error_when_email_could_not_be_found
    post :create, :email => 'doesnotexist@somewhere.com'
    assert flash[:alert]
    assert_template 'new'
  end
  
  def test_should_reset_password_when_email_could_be_found
    @account = accounts(:standard)
    post :create, :email => @account.email
    assert_not_nil @account.reload.password_reset_code
    assert_redirected_to login_url
    assert flash[:notice]
  end
  
  # def test_should_redirect_to_new_if_code_is_missing
  #   get :edit
  #   assert_redirected_to forgot_password_path
  #   assert flash[:alert]
  # end
  # 
  # def test_should_redirect_to_new_if_code_is_invalid
  #   get :edit, :id => 'doesnotexist'
  #   assert_redirected_to forgot_password_path
  #   assert flash[:alert]
  # end
  
  def test_should_reset_the_password_when_it_matches_confirmation
    @account = accounts(:standard)
    old_crypted_password = @account.crypted_password
    @account.forgot_password!
    put :update, :id => @account.password_reset_code,
      :password => 'v4l1d_n3w_pa$$w0rD',
      :password_confirmation => 'v4l1d_n3w_pa$$w0rD'
    assert_not_equal old_crypted_password, @account.reload.crypted_password
    assert_redirected_to login_url
    assert flash[:notice]
  end
  
  def test_should_not_reset_the_password_if_it_is_blank
    @account = accounts(:standard)
    old_crypted_password = @account.crypted_password
    @account.forgot_password!
    new_password = ''
    put :update, :id => @account.password_reset_code,
      :password => new_password,
      :password_confirmation => new_password
    assert_equal old_crypted_password, @account.reload.crypted_password
    assert flash[:alert]
    assert_template 'edit'
  end
  
  def test_should_not_reset_the_password_if_it_does_not_match_confirmation
    @account = accounts(:standard)
    old_crypted_password = @account.crypted_password
    @account.forgot_password!
    put :update, :id => @account.password_reset_code,
      :password => 'v4l1d_n3w_pa$$w0rD',
      :password_confirmation => 'other_password'
    assert_equal old_crypted_password, @account.reload.crypted_password
    assert flash[:alert]
    assert_template 'edit'
  end
end
