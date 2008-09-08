class Persona < ActiveRecord::Base
  belongs_to :account
  has_many :sites, :dependent => :destroy
  
  validates_presence_of :account
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  before_destroy :check_deletable!
  
  attr_protected :account_id, :deletable
  
  class NotDeletable < StandardError; end
  
  def self.properties
    Persona.mappings.keys
  end
  
  # Returns the personas attribute for the given SReg name or AX Type URI
  def property(type)
    prop = Persona.mappings.detect { |i| i[1].include?(type) }
    prop ? self.send(prop[0]).to_s : ""
  end
  
  def date_of_birth
    "#{dob_year? ? dob_year : '0000'}-#{dob_month? ? dob_month : '00'}-#{dob_day? ? dob_day : '00'}"
  end
  
  protected
  
  def check_deletable!
    raise NotDeletable unless deletable
  end
  
  private
  
  # Mappings for SReg names and AX Type URIs to attributes
  def self.mappings
    { 'nickname' => ['nickname', 'http://axschema.org/namePerson/friendly'],
      'email' => ['email', 'http://axschema.org/contact/email'],
      'fullname' => ['fullname', 'http://axschema.org/namePerson'],
      'postcode' => ['postcode', 'http://axschema.org/contact/postalCode/home'],
      'country' => ['country', 'http://axschema.org/contact/country/home'],
      'language' => ['language', 'http://axschema.org/pref/language'],
      'timezone' => ['timezone', 'http://axschema.org/pref/timezone'],
      'gender' => ['gender', 'http://axschema.org/person/gender'],
      'date_of_birth' => ['dob', 'http://axschema.org/birthDate'],
      'dob_day' => ['dob_day', 'http://axschema.org/birthDate/birthday'],
      'dob_month' => ['dob_month', 'http://axschema.org/birthDate/birthMonth'],
      'dob_year' => ['dob_year', 'http://axschema.org/birthDate/birthYear'],
      'address' => ['http://axschema.org/contact/postalAddress/home'],
      'address_additional' => ['http://axschema.org/contact/postalAddressAdditional/home'],
      'city' => ['http://axschema.org/contact/city/home'],
      'state' => ['http://axschema.org/contact/state/home'],
      'company_name' => ['http://axschema.org/company/name'],
      'job_title' => ['http://axschema.org/company/title'],
      'address_business' => ['http://axschema.org/contact/postalAddress/business'],
      'address_additional_business' => ['http://axschema.org/contact/postalAddressAdditional/business'],
      'postcode_business' => ['http://axschema.org/contact/postalCode/business'],
      'city_business' => ['http://axschema.org/contact/city/business'],
      'state_business' => ['http://axschema.org/contact/state/business'],
      'country_business' => ['http://axschema.org/contact/country/business'],
      'phone_home' => ['http://axschema.org/contact/phone/home'],
      'phone_mobile' => ['http://axschema.org/contact/phone/cell'],
      'phone_work' => ['http://axschema.org/contact/phone/business'],
      'phone_fax' => ['http://axschema.org/contact/phone/fax'],
      'im_aim' => ['http://axschema.org/contact/IM/AIM'],
      'im_icq' => ['http://axschema.org/contact/IM/ICQ'],
      'im_msn' => ['http://axschema.org/contact/IM/MSN'],
      'im_yahoo' => ['http://axschema.org/contact/IM/Yahoo'],
      'im_jabber' => ['http://axschema.org/contact/IM/Jabber'],
      'im_skype' => ['http://axschema.org/contact/IM/Skype'],
      'image_default' => ['http://axschema.org/media/image/default'],
      'biography' => ['http://axschema.org/media/biography'],
      'web_default' => ['http://axschema.org/contact/web/default'],
      'web_blog' => ['http://axschema.org/contact/web/blog'] }
  end
  
end
