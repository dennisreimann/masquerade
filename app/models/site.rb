class Site < ActiveRecord::Base
  belongs_to :account
  belongs_to :persona
  has_many :release_policies, :dependent => :destroy
  
  validates_presence_of :url, :persona, :account
  validates_uniqueness_of :url, :scope => :account_id
  attr_accessible :url, :persona_id, :properties
  
  # Sets the release policies by first deleting the old ones
  # and then appending a new one for every given property key.
  def properties=(props)
    release_policies.destroy_all
    props.each_pair do |key, value|
      release_policies.build(:property => key)
    end
  end
  
  # Returns a hash with all released properties
  def properties
    props = {}
    release_policies.each { |rp| props[rp.property] = persona[rp.property].to_s }
    props
  end
  
end
