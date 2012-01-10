# encoding: utf-8

ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'

require "#{Rails.root}/lib/authenticated_test_helper"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include AuthenticatedTestHelper
  
  def valid_account_attributes
    { :login => 'dbloete',
      :email => 'mail@dennisbloete.de',
      :password => '123456',
      :password_confirmation => '123456' }
  end
  
  def valid_persona_attributes
    { :title => 'official',
      :nickname => 'dbloete',
      :email => 'mail@dennisbloete.de',
      :fullname => 'Dennis Blöte',
      :postcode => '28199',
      :country => 'DE',
      :language => 'DE',
      :timezone => 'Europe/Berlin',
      :gender => 'M',
      :dob_day => '10',
      :dob_month => '01',
      :dob_year => '1982' }
  end
  
  def valid_properties
    { 'nickname' => { 'value' => 'dbloete', 'type' => 'nickname' },
      'email' => { 'value' => 'mail@dennisbloete.de', 'type' => 'email' },
      'gender' => { 'value' => 'M', 'type' => 'gender' },
      'dob' => { 'value' => '1982-01-10', 'type' => 'dob' },
      'login' => { 'value' => 'dbloete', 'type'=> 'http://axschema.org/namePerson/friendly' },
      'email_address' => { 'value' => 'mail@dennisbloete.de', 'type' => 'http://axschema.org/contact/email' } }
  end
  
  def valid_site_attributes
    { :url => "http://dennisbloete.de/" }
  end
  
  def valid_country_attributes
    { :name => 'Germany', :code => 'DE' }
  end

  def valid_language_attributes
    { :name => 'German', :code => 'DE' }
  end
  
  def checkid_request_params
    { 'openid.ns' => OpenID::OPENID2_NS,
      'openid.mode' => 'checkid_setup',
      'openid.realm' => 'http://test.com/',
      'openid.trust_root' => 'http://test.com/',
      'openid.return_to' => 'http://test.com/return',
      'openid.claimed_id' => 'http://dennisbloete.de/',
      'openid.identity' => 'http://openid.innovated.de/dbloete' }
  end

  def associate_request_params
    { 'openid.ns' => OpenID::OPENID2_NS,
      'openid.mode' => 'associate',
      'openid.assoc_type' => 'HMAC-SHA1',
      'openid.session_type' => 'DH-SHA1',
      'openid.dh_consumer_public' => 'MgKzyEozjQH6uDumfyCGfDGWW2RM5QRfLi+Yu+h7SuW7l+jxk54/s9mWG+0ZR2J4LmhUO9Cw/sPqynxwqWGQLnxr0wYHxSsBIctUgxp67L/6qB+9GKM6URpv1mPkifv5k1M8hIJTQhzYXxHe+/7MM8BD47vBp0nihjaDr0XAe6w=' }
  end
    
  def sreg_request_params
    { 'openid.ns.sreg' => OpenID::SReg::NS_URI,
      'openid.sreg.required' => 'nickname,email',
      'openid.sreg.optional' => 'fullname,dob',
      'openid.sreg.policy_url' => 'http://test.com/policy.html' }
  end
  
  def ax_fetch_request_params
    { 'openid.ns.ax' => OpenID::AX::AXMessage::NS_URI,
      'openid.ax.mode' => OpenID::AX::FetchRequest::MODE,
      'openid.ax.type.nickname' => 'http://axschema.org/namePerson/friendly',
      'openid.ax.type.gender' => 'http://axschema.org/person/gender',
      'openid.ax.required' => 'nickname',
      'openid.ax.if_available' => 'gender',
      'openid.ax.update_url' => 'http://test.com/update' }
  end
  
  def ax_store_request_params
    { 'openid.ns.ax' => OpenID::AX::AXMessage::NS_URI,
      'openid.ax.mode' => OpenID::AX::StoreRequest::MODE,
      'openid.ax.count.fullname' => 1,
      'openid.ax.type.fullname' => 'http://axschema.org/namePerson',
      'openid.ax.value.fullname.1' => 'Bob "AX Storer" Smith',
      'openid.ax.count.email' => 1,
      'openid.ax.type.email' => 'http://axschema.org/contact/email',
      'openid.ax.value.email.1' => 'new@axstore.com' }
  end
  
  def pape_request_params
    { 'openid.ns.pape' => OpenID::PAPE::NS_URI,
      'openid.pape.max_auth_age' => 3600,
      'openid.pape.preferred_auth_policies' => [
        OpenID::PAPE::AUTH_MULTI_FACTOR_PHYSICAL,
        OpenID::PAPE::AUTH_MULTI_FACTOR,
        OpenID::PAPE::AUTH_PHISHING_RESISTANT].join(' ') }
  end

  def assert_valid(object) # just for work with Rails 2.3.4.
    assert object.valid?
  end

  def assert_invalid(object, attribute, message = "")
    assert_equal false, object.valid?
    assert object.errors[attribute], message
  end
  
  def assert_login_required
    assert_redirected_to login_path
    assert_not_nil @request.session[:return_to]
  end
  
  # verbatim, from ActiveController's own unit tests
  # stolen from http://stackoverflow.com/questions/1165478/testing-http-basic-auth-in-rails-2-2/1258046#1258046
  def encode_credentials(username, password)
    "Basic #{ActiveSupport::Base64.encode64("#{username}:#{password}")}"
  end
end
