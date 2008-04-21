class Site < ActiveRecord::Base
  belongs_to :account
  belongs_to :persona
  has_many :release_policies, :dependent => :destroy
  
  validates_presence_of :url, :persona, :account
  validates_uniqueness_of :url, :scope => :account_id
  attr_accessible :url, :persona_id, :properties, :ax, :sreg
  
  # Sets the release policies by first deleting the old ones and 
  # then appending a new one for every given sreg and ax property.
  def properties=(props)
    release_policies.destroy_all
    props.each_pair do |property, details|
      release_policies.build(:property => property, :type_identifier => details['type']) if details['value']
    end
  end
  
  def ax=(props)
    props.each_pair do |property, details|
      release_policies.build(:property => property, :type_identifier => details['type']) if details['value']
    end
  end
  
  def sreg=(props)
    props.each_key do |property|
      release_policies.build(:property => property, :type_identifier => property)
    end
  end
  
  # Returns a hash with all released SReg properties
  def sreg_properties
    props = {}
    release_policies.each { |rp| props[rp.property] = persona.property(rp.property) if rp.property == rp.type_identifier }
    props
  end
  
  # Returns a hash with all released AX properties
  def ax_properties
    props = {}
    release_policies.each do |rp|
      type = rp.type_identifier 
      unless rp.property == type
        props["type.#{rp.property}"] = type
        props["value.#{rp.property}"] = persona.property(type)
      end
    end
    props
  end
  
end
