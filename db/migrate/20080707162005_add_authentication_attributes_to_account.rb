class AddAuthenticationAttributesToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_authenticated_at, :datetime
    add_column :accounts, :last_authenticated_with_yubikey, :boolean
  end

  def self.down
    remove_column :accounts, :last_authenticated_at
    remove_column :accounts, :last_authenticated_with_yubikey
  end
end
