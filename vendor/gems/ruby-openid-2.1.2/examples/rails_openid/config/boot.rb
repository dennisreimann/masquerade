# Don't change this file. Configuration is done in config/environment.rb and config/environments/*.rb

unless defined?(Rails.root)
  root_path = File.join(File.dirname(__FILE__), '..')
  unless RUBY_PLATFORM =~ /mswin32/
    require 'pathname'
    root_path = Pathname.new(root_path).cleanpath(true).to_s
  end
  Rails.root = root_path
end

if File.directory?("#{Rails.root}/vendor/rails")
  require "#{Rails.root}/vendor/rails/railties/lib/initializer"
else
  require 'rubygems'
  require 'initializer'
end

Rails::Initializer.run(:set_load_path)
