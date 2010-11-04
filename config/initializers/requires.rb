require 'digest/sha1'
require 'yaml'
require 'openid'
require 'openid/consumer/discovery'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'

require "#{Rails.root}/lib/openid_server_system"
require "#{Rails.root}/lib/authenticated_system"
require "#{Rails.root}/lib/yubico"
require "#{Rails.root}/lib/hash"