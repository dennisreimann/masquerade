class AddYubikeyMandatoryToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :yubikey_mandatory, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :accounts, :yubikey_mandatory
  end
end
