require 'rubygems'
require 'openid/extension'
require 'openid/message'

module OpenID
  module AX
    class StoreRequest
      # Extract a StoreRequest from an OpenID message
      def self.from_openid_request(oid_req)
        message = oid_req.message 
        ax_args = message.get_args(NS_URI)
        return nil if ax_args.empty?
        req = new
        req.parse_extension_args(ax_args)
        req
      end
    end

    class StoreResponse
      def self.from_success_response(success_response)
        resp = nil
        ax_args = success_response.message.get_args(NS_URI)
        resp = ax_args.key?('error') ? new(false, ax_args['error']) : new
      end
    end
  end
end