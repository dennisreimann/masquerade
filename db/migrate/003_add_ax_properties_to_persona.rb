class AddAxPropertiesToPersona < ActiveRecord::Migration
  def self.up
    # Personal
    add_column :personas, :address, :string
    add_column :personas, :address_additional, :string
    add_column :personas, :city, :string
    add_column :personas, :state, :string
    # Business
    add_column :personas, :company_name, :string
    add_column :personas, :job_title, :string
    add_column :personas, :address_business, :string
    add_column :personas, :address_additional_business, :string
    add_column :personas, :postcode_business, :string
    add_column :personas, :city_business, :string
    add_column :personas, :state_business, :string
    add_column :personas, :country_business, :string
    # Telephone
    add_column :personas, :phone_home, :string
    add_column :personas, :phone_mobile, :string
    add_column :personas, :phone_work, :string
    add_column :personas, :phone_fax, :string
    # Instant Messaging
    add_column :personas, :im_aim, :string
    add_column :personas, :im_icq, :string
    add_column :personas, :im_msn, :string
    add_column :personas, :im_yahoo, :string
    add_column :personas, :im_jabber, :string
    add_column :personas, :im_skype, :string
    # Images
    add_column :personas, :image_default, :string
    # Other
    add_column :personas, :biography, :string
    add_column :personas, :web_default, :string
    add_column :personas, :web_blog, :string
  end

  def self.down
    # Personal
    remove_column :personas, :address
    remove_column :personas, :address_additional
    remove_column :personas, :city
    remove_column :personas, :state
    # Business
    remove_column :personas, :company_name
    remove_column :personas, :job_title
    remove_column :personas, :address_business
    remove_column :personas, :address_additional_business
    remove_column :personas, :postcode_business
    remove_column :personas, :city_business
    remove_column :personas, :state_business
    remove_column :personas, :country_business
    # Telephone
    remove_column :personas, :phone_home
    remove_column :personas, :phone_mobile
    remove_column :personas, :phone_work
    remove_column :personas, :phone_fax
    # Instant Messaging
    remove_column :personas, :im_aim
    remove_column :personas, :im_icq
    remove_column :personas, :im_msn
    remove_column :personas, :im_yahoo
    remove_column :personas, :im_jabber
    remove_column :personas, :im_skype
    # Images
    remove_column :personas, :image_default
    # Other
    remove_column :personas, :biography
    remove_column :personas, :web_default
    remove_column :personas, :web_blog
  end
end
