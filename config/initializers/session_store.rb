# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_masquerade_session',
  :secret => '22e105c55211782443814e7e5b73a0ea8e6f4d67dc0b7395549094b547fed0732a47444e7f4e5a68b4fc4da635edd7967a708484ce8d5ae44747d14191a90efe'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
