class OpenIdRequest < ActiveRecord::Base
  
  validates_presence_of :token
  validates_presence_of :parameters
  
  before_validation_on_create :make_token
  
  serialize :parameters, Hash
  
  def parameters=(params)
    self[:parameters] = params.is_a?(Hash) ? params.delete_if { |k,v| k.index('openid.') != 0 } : nil
  end
  
  private
  
  def make_token
    self.token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
end
