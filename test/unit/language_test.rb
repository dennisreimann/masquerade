require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  
  def setup
    @language = Language.new valid_language_attributes
  end
  
  def test_should_require_name
    @language.name = nil
    assert_invalid @language, :name
  end
  
  def test_should_require_code
    @language.code = nil
    assert_invalid @language, :code
  end
  
end
