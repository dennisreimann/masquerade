require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

require 'digest/sha1'
require 'openid'
require 'openid/consumer/discovery'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'
require 'lib/openid_server_system'
require 'lib/yubico'
require 'lib/hash'
require 'yaml'

module Masquerade
  class Application < Rails::Application
    
    Masquerade::Application::Config = YAML.load(File.read("#{Rails.root}/config/app_config.yml"))[Rails.env]
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    config.active_record.observers = :account_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = Masquerade::Application::Config['time_zone'] || 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    config.i18n.default_locale = Masquerade::Application::Config['locale'] || :en
    
    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :test_unit, :fixture => true
    end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << [:password, :token]
    
    # Mailer
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address => Masquerade::Application::Config['mailer']['address'],
      :domain => Masquerade::Application::Config['mailer']['domain'],
      :port => Masquerade::Application::Config['mailer']['port'],
      :user_name => Masquerade::Application::Config['mailer']['user_name'],
      :password => Masquerade::Application::Config['mailer']['password'],
      :authentication => Masquerade::Application::Config['mailer']['authentication'] }
    config.action_mailer.default_url_options = {
      :protocol => (Masquerade::Application::Config['use_ssl'] ? 'https' : 'http'),
      :host => Masquerade::Application::Config['host'] }
      
  end
end

