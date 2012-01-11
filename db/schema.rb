# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120111002919) do

  create_table "accounts", :force => true do |t|
    t.boolean  "enabled",                                       :default => true
    t.string   "login",                                                            :null => false
    t.string   "email",                                                            :null => false
    t.string   "crypted_password",                :limit => 40,                    :null => false
    t.string   "salt",                            :limit => 40,                    :null => false
    t.string   "remember_token"
    t.string   "password_reset_code",             :limit => 40
    t.string   "activation_code",                 :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "yubico_identity",                 :limit => 12
    t.integer  "public_persona_id"
    t.datetime "last_authenticated_at"
    t.boolean  "last_authenticated_with_yubikey"
    t.boolean  "yubikey_mandatory",                             :default => false, :null => false
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["login"], :name => "index_accounts_on_login", :unique => true

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.binary  "secret"
    t.string  "handle"
    t.string  "assoc_type"
    t.integer "issued"
    t.integer "lifetime"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url", :null => false
    t.string  "salt",       :null => false
    t.integer "timestamp",  :null => false
  end

  create_table "open_id_requests", :force => true do |t|
    t.string   "token",      :limit => 40
    t.text     "parameters"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "open_id_requests", ["token"], :name => "index_open_id_requests_on_token", :unique => true

  create_table "personas", :force => true do |t|
    t.integer  "account_id",                                                 :null => false
    t.string   "title",                                                      :null => false
    t.string   "nickname"
    t.string   "email"
    t.string   "fullname"
    t.string   "postcode"
    t.string   "country"
    t.string   "language"
    t.string   "timezone"
    t.string   "gender",                      :limit => 1
    t.boolean  "deletable",                                :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "address_additional"
    t.string   "city"
    t.string   "state"
    t.string   "company_name"
    t.string   "job_title"
    t.string   "address_business"
    t.string   "address_additional_business"
    t.string   "postcode_business"
    t.string   "city_business"
    t.string   "state_business"
    t.string   "country_business"
    t.string   "phone_home"
    t.string   "phone_mobile"
    t.string   "phone_work"
    t.string   "phone_fax"
    t.string   "im_aim"
    t.string   "im_icq"
    t.string   "im_msn"
    t.string   "im_yahoo"
    t.string   "im_jabber"
    t.string   "im_skype"
    t.string   "image_default"
    t.string   "biography"
    t.string   "web_default"
    t.string   "web_blog"
    t.integer  "dob_day",                     :limit => 2
    t.integer  "dob_month",                   :limit => 2
    t.integer  "dob_year"
  end

  add_index "personas", ["account_id", "title"], :name => "index_personas_on_account_id_and_title", :unique => true

  create_table "release_policies", :force => true do |t|
    t.integer "site_id",         :null => false
    t.string  "property",        :null => false
    t.string  "type_identifier"
  end

  add_index "release_policies", ["site_id", "property", "type_identifier"], :name => "unique_property", :unique => true

  create_table "sites", :force => true do |t|
    t.integer  "account_id", :null => false
    t.integer  "persona_id", :null => false
    t.string   "url",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["account_id", "url"], :name => "index_sites_on_account_id_and_url", :unique => true

end
