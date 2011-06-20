require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  def test_should_set_yadis_header_on_homepage
    get :index
    assert_match server_url(:format => :xrds), @response.headers['X-XRDS-Location']
  end

  def test_should_show_registration_link_if_enabled
    Masquerade::Application::Config['disable_registration'] = false
    get :index
    assert_select "ul#navi li a", {:text => I18n.t(:signup_link), :count => 1}
  end

  def test_should_not_show_registration_link_if_disabled
    Masquerade::Application::Config['disable_registration'] = true
    get :index
    assert_select "ul#navi li a", {:text => I18n.t(:signup_link), :count => 0}
  end

  def test_should_not_show_registration_link_on_index_if_disable_registration_is_enabled
    Masquerade::Application::Config['disable_registration'] = false
    get :index
    text = I18n.t(:openid_intro_link, :signup_link => I18n.t(:signup_for_an_openid))
    text = text[3..-5] # cut <p> and </p> -- ugly :(
    assert_select "p:nth-child(3)", {:text => text, :count => 1}
  end

  def test_should_show_registration_link_on_index_if_disable_registration_is_disabled
    Masquerade::Application::Config['disable_registration'] = true
    get :index
    assert_select "p:nth-child(3)", {:text => I18n.t(:openid_intro_link, :signup_link => I18n.t(:signup_for_an_openid)), :count => 0}
  end

  def test_should_show_logout_link_after_cookie_login
    accounts(:standard).remember_me
    @request.cookies["auth_token"] = accounts(:standard).remember_token
    get :index
    assert @controller.send(:logged_in?)
    assert_select "ul#navi li a", {:text => I18n.t(:logout), :count => 1}
  end

  def test_should_show_logout_link_after_session_login
    login_as :standard
    get :index
    assert @controller.send(:logged_in?)
    assert_select "ul#navi li a", {:text => I18n.t(:logout), :count => 1}
  end

  def test_should_not_show_logout_link_after_basic_login
    @request.env['HTTP_AUTHORIZATION'] = encode_credentials(accounts(:standard).login, 'test')
    get :index
    assert @controller.send(:logged_in?)
    assert @controller.send(:auth_type_used) == :basic
    assert_select "ul#navi li a", {:text => I18n.t(:logout), :count => 0}
  end

end
