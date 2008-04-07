require File.dirname(__FILE__) + '/../test_helper'

class SitesControllerTest < ActionController::TestCase
  
  fixtures :accounts, :sites, :personas
 
  def test_should_require_login_for_index
    get :index
    assert_login_required
  end
   
  def test_should_have_list_of_sites_on_index
    login_as(:standard)
    get :index
    assert_response :success
    assert_not_nil assigns(:sites)
  end

  def test_should_require_login_for_edit
    get :edit, :id => sites(:venteria).id
    assert_login_required
  end
  
  def test_should_get_edit
    login_as(:standard)
    get :edit, :id => sites(:venteria).id
    assert_response :success
  end
  
  def test_should_require_login_for_update
    put :update, :id => sites(:venteria).id, :site => valid_site_attributes
    assert_login_required
  end
  
  def test_should_update_site
    login_as(:standard)
    @site = sites(:venteria)
    put :update, :id => @site.id, :site => valid_site_attributes
    assert_redirected_to edit_account_site_path(@site)
  end

  def test_should_update_release_policies_on_site_update
    login_as(:standard)
    @site = sites(:venteria)
    put :update, :id => @site.id,
      :site => valid_site_attributes.merge(:properties => valid_properties)
    assert_equal valid_properties.size, @site.release_policies.size
  end

  def test_should_require_login_for_destroy
    delete :destroy, :id => sites(:venteria).id
    assert_login_required
  end

  def test_should_destroy_site
    login_as(:standard)
    assert_difference('Site.count', -1) do
      delete :destroy, :id => sites(:venteria).id
    end
    assert_redirected_to account_sites_path
  end
end
