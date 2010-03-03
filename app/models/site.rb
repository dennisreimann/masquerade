class Site < ActiveRecord::Base
  belongs_to :account
  belongs_to :persona
  has_many :release_policies, :dependent => :destroy
  
  validates_presence_of :url, :persona, :account
  validates_uniqueness_of :url, :scope => :account_id
  attr_accessible :url, :persona_id, :properties, :ax_fetch, :sreg
  
  # Sets the release policies by first deleting the old ones and
  # then appending a new one for every given sreg and ax property.
  # This setter is used to set the attributes recieved from the
  # update site form, so it gets passed AX and SReg properties.
  # To be backwards compatible (SReg seems to be obsolete now that
  # there is AX), SReg properties get a type_identifier matching
  # their property name so that they can be distinguished from AX
  # properties (see the sreg_properties and ax_properties getters).
  def properties=(props)
    release_policies.destroy_all
    props.each_pair do |property, details|
      release_policies.build(:property => property, :type_identifier => details['type']) if details['value']
    end
  end
  
  # Generates a release policy for each property that has a value.
  # This setter is used in the server controllers complete action
  # to set the attributes recieved from the decision form.
  def ax_fetch=(props)
    props.each_pair do |property, details|
      release_policies.build(:property => property, :type_identifier => details['type']) if details['value']
    end
  end
  
  # Generates a release policy for each SReg property.
  # This setter is used in the server controllers complete action
  # to set the attributes recieved from the decision form.
  def sreg=(props)
    props.each_key do |property|
      release_policies.build(:property => property, :type_identifier => property)
    end
  end
  
  # Returns a hash with all released SReg properties. SReg properties
  # have a type_identifier matching their property name
  def sreg_properties
    props = {}
    release_policies.each do |rp|
      is_sreg = (rp.property == rp.type_identifier)
      props[rp.property] = persona.property(rp.property) if is_sreg
    end
    props
  end
  
  # Returns a hash with all released AX properties.
  # AX properties have an URL as type_identifier.
  def ax_properties
    props = {}
    release_policies.each do |rp|
      if rp.type_identifier.match("://")
        props["type.#{rp.property}"] = rp.type_identifier 
        props["value.#{rp.property}"] = persona.property(rp.type_identifier )
      end
    end
    props
  end
  
end
