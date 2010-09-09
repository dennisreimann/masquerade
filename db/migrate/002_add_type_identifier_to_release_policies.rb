class AddTypeIdentifierToReleasePolicies < ActiveRecord::Migration
  def self.up
    add_column :release_policies, :type_identifier, :string
    ReleasePolicy.find(:all).each do |release_policy|
      release_policy.update_attribute(:type_identifier, release_policy.property)
    end
    remove_index :release_policies, :column => [:site_id, :property]
    add_index :release_policies, [:site_id, :property, :type_identifier], :unique => true, :name => 'unique_property'
  end

  def self.down
    remove_column :release_policies, :type_identifier
  end
end
