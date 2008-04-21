require File.dirname(__FILE__) + '/../test_helper'

class ReleasePolicyTest < ActiveSupport::TestCase
  
  fixtures :release_policies
  
  def setup
    @release_policy = release_policies(:venteria_nickname)
  end
  
  def test_should_require_site
    @release_policy.site = nil
    assert_invalid @release_policy, :site
  end
  
  def test_should_be_unique_for_property_across_site_and_type_identifier
    @other_release_policy = release_policies(:venteria_email)
    @other_release_policy.property = @release_policy.property
    @other_release_policy.type_identifier = @release_policy.type_identifier
    assert_invalid @other_release_policy, :property
  end
  
end