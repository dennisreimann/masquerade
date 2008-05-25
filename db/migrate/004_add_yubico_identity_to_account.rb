class AddYubicoIdentityToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :yubico_identity, :string, :limit => 12
  end

  def self.down
    remove_column :accounts, :yubico_identity
  end
end
