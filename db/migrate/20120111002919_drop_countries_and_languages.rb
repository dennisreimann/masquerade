class DropCountriesAndLanguages < ActiveRecord::Migration
  def self.up
    drop_table :countries
    drop_table :languages
  end

  def self.down
    create_table :countries, :force => true do |t|
      t.string :name, :null => false, :limit => 60
      t.string :code, :null => false, :limit => 5
    end

    add_index :countries, :code, :unique => true

    create_table :languages do |t|
      t.string :name, :null => false, :limit => 60
      t.string :code, :null => false, :limit => 5
    end
  end
end
