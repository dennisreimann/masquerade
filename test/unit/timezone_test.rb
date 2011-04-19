require 'test_helper'

class TimezoneTest < ActiveSupport::TestCase
  
  def setup
    @timezone = Timezone.new valid_timezone_attributes
  end
  
  def test_should_require_name
    @timezone.name = nil
    assert_invalid @timezone, :name
  end
  
end
