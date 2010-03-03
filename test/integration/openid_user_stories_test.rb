require "#{File.dirname(__FILE__)}/../test_helper"

class OpenidUserStoriesTest < ActionController::IntegrationTest
  fixtures :all
  
  def test_verifying_identifier_ownership
    claimed_id = "http://www.example.com/quentin"
    request_params = checkid_request_params.merge(
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id)
    # OpenID requests comes in
    post '/server', request_params 
    # User has to log in
    assert_redirected_to safe_login_url
    post '/session', :login => 'quentin', :password => 'test'
    # User has to verify the request
    assert_redirected_to proceed_url
    follow_redirect!
    assert_redirected_to decide_url
    follow_redirect!
    assert_template 'server/decide'
    post 'server/complete', :temporary => 1
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?("mode=id_res")
  end
  
  def test_providing_sreg_data
    @account = accounts(:standard)
    @persona = @account.personas.first
    claimed_id = "http://www.example.com/quentin"
    request_params = checkid_request_params.merge(
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id).merge(
      sreg_request_params)
    # OpenID requests comes in
    post '/server', request_params 
    # User has to log in
    assert_redirected_to safe_login_url
    post '/session', :login => @account.login, :password => 'test'
    # User has to verify the request
    assert_redirected_to proceed_url
    follow_redirect!
    assert_redirected_to decide_url
    follow_redirect!
    assert_template 'server/decide'
    post 'server/complete', :temporary => 1, :site => { :persona_id => @persona.id, :sreg => { 'nickname' => @persona.nickname } }
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?("openid.mode=id_res")
    assert @response.redirect_url_match?("openid.sreg.nickname=#{@persona.nickname}"), "Response was expected to have SReg nickname"
  end
  
  def test_providing_data_without_persona
    @account = accounts(:standard)
    @account.personas.each { |p| p.destroy }
    claimed_id = "http://www.example.com/quentin"
    request_params = checkid_request_params.merge(
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id).merge(
      sreg_request_params)
    # OpenID requests comes in
    post '/server', request_params 
    # User has to log in
    assert_redirected_to safe_login_url
    post '/session', :login => @account.login, :password => 'test'
    # User has to verify the request
    assert_redirected_to proceed_url
    follow_redirect!
    assert_redirected_to decide_url
    follow_redirect!
    assert_template 'server/decide'
    assert_match I18n.translate(:create_persona_link), @response.body
  end

  def test_responding_to_immidiate_requests_when_already_logged_in
    claimed_id = "http://www.example.com/quentin"
    request_params = checkid_request_params.merge(
      'openid.mode' => 'checkid_immediate',
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id)
    # User will be logged in when the request comes in
    post '/session', :login => 'quentin', :password => 'test'
    post '/server', request_params
    # Request has to be answered directly
    assert_redirected_to proceed_url
    follow_redirect!
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?("mode=id_res")
  end

  def test_trusting_a_site_and_responding_with_the_stored_release_policy_on_subsequent_requests
    @account = accounts(:standard)
    @persona = @account.personas.first
    claimed_id = "http://www.example.com/#{@account.login}"
    request_params = checkid_request_params.merge(
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id).merge(
      sreg_request_params)
    # User will be logged in when the request comes in
    post '/session', :login => @account.login, :password => 'test'
    post '/server', request_params
    # User verifies the request and stores the details for this site
    assert_redirected_to proceed_url
    follow_redirect!
    assert_redirected_to decide_url
    follow_redirect!
    assert_template 'server/decide'
    post 'server/complete', :always => 1, :site => { 
      :persona_id => @persona.id,
      :url => checkid_request_params['openid.trust_root'],
      :sreg => { 'nickname' => @persona.nickname } }
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?("mode=id_res"), "Response mode was expected to be id_res"
    assert @response.redirect_url_match?("openid.sreg.nickname=#{@persona.nickname}"), "Response was expected to have SReg nickname"
    # Has the site been saved?
    assert_not_nil @account.sites.find_by_url(checkid_request_params['openid.trust_root'])
    # Now comes the second request
    post '/server', request_params
    assert_redirected_to proceed_url
    follow_redirect!
    assert @response.redirect_url_match?("mode=id_res"), "Response mode was expected to be id_res on subsequent request"
    assert @response.redirect_url_match?("openid.sreg.nickname=#{@persona.nickname}"), "Response was expected to have SReg nickname on subsequent request"
  end
  
  def test_providing_ax_data
    @account = accounts(:standard)
    @persona = @account.personas.first
    claimed_id = "http://www.example.com/quentin"
    request_params = checkid_request_params.merge(
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id).merge(
      ax_fetch_request_params)
    # OpenID requests comes in
    post '/server', request_params 
    # User has to log in
    assert_redirected_to safe_login_url
    post '/session', :login => 'quentin', :password => 'test'
    # User has to verify the request
    assert_redirected_to proceed_url
    follow_redirect!
    assert_redirected_to decide_url
    follow_redirect!
    assert_template 'server/decide'
    post 'server/complete', :temporary => 1, :site => {
      :persona_id => @persona.id,
      :ax_fetch => { 
        'nickname' => { 'type' => 'http://axschema.org/namePerson/friendly', 'value' => @persona.nickname },
        'gender' => { 'type' => 'http://axschema.org/person/gender', 'value' => @persona.gender } } }
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?("openid.mode=id_res"), "Response mode was expected to be id_res"
    assert @response.redirect_url_match?("openid.ax.mode=fetch_response"), "AX mode was expected to be fetch_response"
    assert @response.redirect_url_match?(@persona.nickname), "Response was expected to have AX nickname: #{@response.redirect_url}"
    assert @response.redirect_url_match?(@persona.gender), "Response was expected to have AX gender: #{@response.redirect_url}"
  end
  
  def test_storing_ax_data
    @account = accounts(:standard)
    @persona = @account.personas.first
    claimed_id = "http://www.example.com/quentin"
    request_params = checkid_request_params.merge(
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id).merge(
      ax_store_request_params)
    # OpenID requests comes in
    post '/server', request_params 
    # User has to log in
    assert_redirected_to safe_login_url
    post '/session', :login => 'quentin', :password => 'test'
    # User has to verify the request
    assert_redirected_to proceed_url
    follow_redirect!
    assert_redirected_to decide_url
    follow_redirect!
    assert_template 'server/decide'
    sent_fullname = ax_store_request_params['openid.ax.value.fullname.1']
    sent_email = ax_store_request_params['openid.ax.value.email.1']
    # Simulate accepting the fullname but not the email
    post 'server/complete', :temporary => 1, :site => {
      :persona_id => @persona.id,
      :ax_store => { 
        'fullname' => { 'type' => ax_store_request_params['openid.ax.type.fullname'], 'value' => sent_fullname },
        'email' => { 'type' => ax_store_request_params['openid.ax.type.email'] } } }
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to'])
    assert @response.redirect_url_match?("openid.mode=id_res"), "Response mode was expected to be id_res"
    assert @response.redirect_url_match?("openid.ax.mode=store_response"), "AX mode was expected to be store_response"
    # Check the attributes
    @persona.reload
    assert_equal sent_fullname, @persona.fullname, "Full name was expected to be #{sent_fullname}"
    assert_not_equal sent_email, @persona.email, "E-mail was not expected to be #{sent_email}"
  end
  
  def test_responding_to_pape_requests
    claimed_id = "http://www.example.com/quentin"
    request_params = checkid_request_params.merge(
      'openid.identity' => claimed_id,
      'openid.claimed_id' => claimed_id).merge(
      pape_request_params)
    # OpenID requests comes in
    post '/server', request_params 
    # User has to log in
    assert_redirected_to safe_login_url
    post '/session', :login => 'quentin', :password => 'test'
    # User has to verify the request
    assert_redirected_to proceed_url
    follow_redirect!
    assert_redirected_to decide_url
    follow_redirect!
    assert_template 'server/decide'
    post 'server/complete', :temporary => 1
    assert @response.redirect_url_match?(checkid_request_params['openid.return_to']), "Redirected to: #{@response.redirect_url}"
    assert @response.redirect_url_match?("openid.mode=id_res"), "Response mode was expected to be id_res"
    assert @response.redirect_url_match?("openid.pape.auth_policies=")
    assert @response.redirect_url_match?("openid.pape.auth_time="), "Response was expected to have PAPE Auth Age: #{@response.redirect_url}"
    assert @response.redirect_url_match?("openid.pape.nist_auth_level="), "Response was expected to have PAPE NIST Auth Level: #{@response.redirect_url}"
  end
end
