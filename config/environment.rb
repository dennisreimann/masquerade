# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Load custom config file for current environment
require 'yaml'
APP_CONFIG = YAML.load(File.read(RAILS_ROOT + "/config/app_config.yml"))[RAILS_ENV]

Rails::Initializer.run do |config|

  # Activate Observers
  config.active_record.observers = [:account_observer]

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = APP_CONFIG['session']
  
  # Make Active Record use UTC-base instead of local time
  #config.active_record.default_timezone = :utc
  
  # Mailer
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => APP_CONFIG['mailer']['address'],
    :domain => APP_CONFIG['mailer']['domain'],
    :port => APP_CONFIG['mailer']['port'],
    :user_name => APP_CONFIG['mailer']['user_name'],
    :password => APP_CONFIG['mailer']['password'],
    :authentication => APP_CONFIG['mailer']['authentication'] }
  
  # Gems
  config.gem 'ruby-openid', :lib => 'openid', :version => '2.0.4'
  config.gem 'ruby-yadis', :lib => 'yadis' , :version => '0.3.4'
end