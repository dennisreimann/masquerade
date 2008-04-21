class Persona < ActiveRecord::Base
  belongs_to :account
  has_many :sites, :dependent => :destroy
  
  validates_presence_of :account
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  before_destroy :check_deletable!
  
  attr_accessible :title, :nickname, :email, :fullname, :postcode
  attr_accessible :country, :language, :timezone, :gender, :dob
  
  class NotDeletable < StandardError; end
  
  def self.properties
    Persona.mappings.keys
  end
  
  # Returns the personas attribute for the given SReg name or AX Type URI
  def property(type)
    prop = Persona.mappings.detect { |i| i[1].include?(type) }
    prop ? self[prop[0]].to_s : ""
  end
  
  protected
  
  def check_deletable!
    raise NotDeletable unless deletable
  end
  
  private
  
  # Mappings for SReg names and AX Type URIs to attributes
  def self.mappings
    { 'nickname' => ['nickname', 'http://axschema.org/namePerson/friendly'],
      'email'    => ['email', 'http://axschema.org/contact/email'],
      'fullname' => ['fullname', 'http://axschema.org/namePerson'],
      'postcode' => ['postcode', 'http://axschema.org/contact/postalCode/home'],
      'country'  => ['country', 'http://axschema.org/contact/country/home'],
      'language' => ['language', 'http://axschema.org/pref/language'],
      'timezone' => ['timezone', 'http://axschema.org/pref/timezone'],
      'gender'   => ['gender', 'http://axschema.org/person/gender'],
      'dob'      => ['dob', 'http://axschema.org/birthDate'] }
  end
  
end
