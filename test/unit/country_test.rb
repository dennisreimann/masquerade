require File.dirname(__FILE__) + '/../test_helper'

class CountryTest < ActiveSupport::TestCase
  
  def setup
    @country = Country.new valid_country_attributes
  end
  
  def test_should_require_name
    @country.name = nil
    assert_invalid @country, :name
  end
  
  def test_should_require_code
    @country.code = nil
    assert_invalid @country, :code
  end
  
end
