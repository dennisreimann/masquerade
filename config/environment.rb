# Load the rails application
require File.expand_path('../application', __FILE__)
require 'mysql_utf8' if RUBY_VERSION >= "1.9"

# Initialize the rails application
Masquerade::Application.initialize!
