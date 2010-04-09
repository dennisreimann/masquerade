require File.dirname(__FILE__) + '/../test_helper'

class ServerControllerTest < ActionController::TestCase
  
  fixtures :accounts, :personas

  def test_should_redirect_to_safe_login_page_if_untrusted_domain
    login_as(:standard)
    post :index, checkid_request_params
    assert_redirected_to safe_login_url
    assert_not_nil @request.session[:return_to]
    assert_not_nil @request.session[:request_token]
  end

  def test_should_redirect_to_login_page_if_trusted_domain
    login_as(:standard)
    domain = APP_CONFIG['trusted_domains'].first
    post :index, checkid_request_params.merge('openid.trust_root' => "http://#{domain}/", 'openid.realm' => "http://#{domain}/", 'openid.return_to' => "http://#{domain}/return")
    assert_redirected_to login_url
    assert_not_nil @request.session[:return_to]
    assert_not_nil @request.session[:request_token]
  end

  def test_should_save_site_if_user_chose_to_trust_always
    fake_checkid_request(:standard)
    assert_difference('Site.count', 1) do
      post :complete, :always => 1,
        :site => {
          :persona_id => personas(:public).id,
          :url => checkid_request_params['openid.trust_root'],
          :properties => valid_properties }
    end
    assert_response :redirect
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?(/mode=id_res/)
  end
  
  def test_should_not_save_site_if_user_chose_to_trust_temporary
    fake_checkid_request(:standard)
    assert_no_difference('Site.count') do
      post :complete, :temporary => 1,
        :site => valid_site_attributes.merge(:properties => valid_properties)
    end
    assert_response :redirect
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?(/mode=id_res/)
  end
  
  def test_should_redirect_to_openid_cancel_url_if_user_chose_to_cancel
    fake_checkid_request(:standard)
    post :complete, :cancel => 1
    assert_response :redirect
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?(/mode=cancel/)
  end
  
  def test_should_ask_user_to_login_if_claimed_id_does_not_belong_to_current_account
    login_as(:standard)
    id_url = "http://notmine.com"
    post :index, checkid_request_params.merge('openid.identity' => id_url, 'openid.claimed_id' => id_url)
    assert_redirected_to safe_login_url
    assert_not_nil @request.session[:return_to]
    assert_not_nil @request.session[:request_token]
  end
  
  def test_should_clear_old_request_when_recieving_a_new_one
    fake_checkid_request(:standard)
    token_for_first_request = @request.session[:request_token]
    assert token_for_first_request
    post :index
    assert_not_equal @request.session[:request_token], token_for_first_request
    assert_nil OpenIdRequest.find_by_token(token_for_first_request)
  end
  
  def test_should_directly_answer_incoming_associate_requests
    post :index, associate_request_params
    assert_response :success
    assert_match 'assoc_handle', @response.body
    assert_match 'assoc_type', @response.body
    assert_match 'session_type', @response.body
    assert_match 'expires_in', @response.body
  end
  
  def test_should_require_login_for_proceed
    get :proceed
    assert_login_required
  end
  
  def test_should_require_login_for_decide
    get :decide
    assert_login_required
  end

  def test_should_require_login_for_complete
    get :complete
    assert_login_required
  end
  
  private
  
  # Takes the name of an account fixture for which to fake the request
  def fake_checkid_request(account)
    login_as(account)
    id_url = identifier(accounts(account))
    openid_params = checkid_request_params.merge('openid.identity' => id_url, 'openid.claimed_id' => id_url)
    @checkid_request = OpenIdRequest.create(:parameters => openid_params)
    @request.session[:request_token] = @checkid_request.token
  end
  
  def identifier(account)
    "http://test.host/#{account.login}"
  end
  
end
