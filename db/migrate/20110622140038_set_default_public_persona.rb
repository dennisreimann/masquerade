class SetDefaultPublicPersona < ActiveRecord::Migration
  class Persona < ActiveRecord::Base
  end

  class Account < ActiveRecord::Base
    belongs_to :public_persona, :class_name => 'SetDefaultPublicPersona::Persona'
    has_many :personas, :class_name => 'SetDefaultPublicPersona::Persona', :order => 'id ASC'
  end
  
  def self.up
    Account.where(:public_persona_id => nil).each do |account|
      account.update_attribute(:public_persona_id, account.personas.first.id)
    end
  end

  def self.down
  end
end
