require File.dirname(__FILE__) + '/../test_helper'

class PersonaTest < ActiveSupport::TestCase
  
  fixtures :personas
  
  def setup
    @persona = personas(:public)
  end

  def test_should_require_account
    @persona.account = nil
    assert_invalid @persona, :account
  end
  
  def test_should_require_title
    @persona.title = nil
    assert_invalid @persona, :title
  end
  
  def test_should_have_unique_title_across_account
    @persona.title = personas(:private).title
    assert_invalid @persona, :title
  end

  def test_should_raise_not_deletable_on_destroy_if_not_flagged_deletable
    @persona.update_attribute(:deletable, false)
    assert_raises Persona::NotDeletable do
      @persona.destroy
    end
  end
  
end