class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |t|
      t.boolean :enabled, :default => true
      t.string :login, :email, :null => false
      t.string :crypted_password, :salt, :limit => 40, :null => false
      t.string :remember_token
      t.string :password_reset_code, :activation_code, :limit => 40
      t.datetime :remember_token_expires_at, :activated_at
      t.timestamps
    end
    
    add_index :accounts, :login, :unique => true
    add_index :accounts, :email, :unique => true
    
    create_table :personas do |t|
      t.integer :account_id, :null => false
      t.string :title, :null => false
      t.string :nickname, :email, :fullname, :postcode, :country, :language, :timezone
      t.string :gender, :limit => 1
      t.date :dob
      t.boolean :deletable, :null => false, :default => true
      t.timestamps
    end
    
    add_index :personas, [:account_id, :title], :unique => true
    
    create_table :sites do |t|
      t.integer :account_id, :persona_id, :null => false
      t.string :url, :null => false
      t.timestamps
    end
    
    add_index :sites, [:account_id, :url], :unique => true
    
    create_table :release_policies do |t|
      t.integer :site_id, :null => false
      t.string :property, :null => false
    end
    
    add_index :release_policies, [:site_id, :property], :unique => true
    
    create_table :open_id_associations, :force => true do |t|
      t.binary :server_url, :secret
      t.string :handle, :assoc_type
      t.integer :issued, :lifetime
    end

    create_table :open_id_nonces, :force => true do |t|
      t.string :server_url, :salt, :null => false
      t.integer :timestamp, :null => false
    end
    
    create_table :open_id_requests, :force => true do |t|
      t.string :token, :limit => 40
      t.text :parameters
      t.timestamps
    end
    
    add_index :open_id_requests, :token, :unique => true
    
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
  
  def self.down
    drop_table :accounts
    drop_table :countries
    drop_table :languages
    drop_table :open_id_associations
    drop_table :open_id_nonces
    drop_table :open_id_requests
    drop_table :personas
    drop_table :release_policies
    drop_table :sites
  end
end
