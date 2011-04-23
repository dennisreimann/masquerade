require 'test_helper'

class PersonasControllerTest < ActionController::TestCase

  fixtures :accounts, :personas
  
  def test_should_require_login_for_index
    get :index
    assert_login_required
  end
  
  def test_should_have_list_of_personas_on_index
    login_as(:standard)
    get :index
    assert_response :success
    assert_not_nil assigns(:personas)
  end
  
  def test_should_require_login_for_new
    get :new
    assert_login_required
  end

  def test_should_get_new
    login_as(:standard)
    get :new
    assert_response :success
  end

  def test_should_require_login_for_create
    post :create, :persona => valid_persona_attributes
    assert_login_required
  end

  def test_should_create_persona
    login_as(:standard)
    assert_difference('Persona.count', 1) do
      post :create, :persona => valid_persona_attributes
    end
    assert_redirected_to account_personas_path
  end

  def test_should_require_login_for_edit
    get :edit, :id => personas(:public).id
    assert_login_required
  end

  def test_should_get_edit
    login_as(:standard)
    get :edit, :id => personas(:public).id
    assert_response :success
  end

  def test_should_require_login_for_update
    put :update, :id => personas(:public).id, :persona => valid_persona_attributes
    assert_login_required
  end

  def test_should_update_persona
    login_as(:standard)
    put :update, :id => personas(:public).id, :persona => valid_persona_attributes
    assert_redirected_to account_personas_path
  end
  
  def test_should_require_login_for_destroy
    delete :destroy, :id => personas(:public).id
    assert_login_required
  end
  
  def test_should_destroy_persona
    login_as(:standard)
    assert_difference('Persona.count', -1) do
      delete :destroy, :id => personas(:public).id
    end
    assert_redirected_to account_personas_path
  end

end
