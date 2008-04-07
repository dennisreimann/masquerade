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
  
  # Returns an array with all supported property keys.
  def self.properties
    %w(nickname email fullname postcode country language timezone gender dob)
  end
  
  protected
  
  def check_deletable!
    raise NotDeletable unless deletable
  end
end
