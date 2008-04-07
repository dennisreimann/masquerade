require File.dirname(__FILE__) + '/../test_helper'

class OpenIdRequestTest < ActiveSupport::TestCase
  
  def setup
    @request = OpenIdRequest.create :parameters => checkid_request_params
  end

  def test_should_require_token
    @request.token = nil
    assert_invalid @request, :token
  end
  
  def test_should_generate_token_on_create
    @request = OpenIdRequest.new :parameters => checkid_request_params
    assert_nil @request.token
    assert @request.save
    assert_not_nil @request.token
  end
  
  def test_should_require_parameters
    @request.parameters = nil
    assert_invalid @request, :parameters
  end
  
  def test_should_reject_non_openid_parameters
    various_params = checkid_request_params.merge('test' => 1, 'foo' => 'bar')
    @request.parameters = various_params
    assert !@request.parameters.include?('test')
    assert !@request.parameters.include?('bar')
  end
  
end
