class AddPublicPersona < ActiveRecord::Migration
  def self.up
    add_column :accounts, :public_persona_id, :integer
  end

  def self.down
    remove_column :accounts, :public_persona_id
  end
end
