require File.dirname(__FILE__) + '/../test_helper'

class InfoControllerTest < ActionController::TestCase
  
  def test_should_set_yadis_header_on_homepage
    get :index
    assert_match formatted_server_path(:xrds), @response.headers['X-XRDS-Location']
  end
  
end
