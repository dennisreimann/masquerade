# This module is mainly a wrapper for the OpenID::Server functionality provided
# by the ruby-openid gem. Included in your server controller it gives you some
# helpful methods to access and answer OpenID requests.
module OpenidServerSystem
  
  protected
  
  # OpenID store reader, used inside this module 
  # to procide access to the storage machanism
  def openid_store
    @openid_store ||= ActiveRecordStore.new
  end
  
  # OpenID server reader, use this to access the server 
  # functionality from inside your server controller
  def openid_server
    @openid_server ||= OpenID::Server::Server.new(openid_store, endpoint_url)
  end
  
  # OpenID parameter reader, use this to access only OpenID 
  # request parameters from inside your server controller
  def openid_params
    @openid_params ||= params.clone.delete_if { |k,v| k.index('openid.') != 0 }
  end

  # OpenID request accessor
  def openid_request
    @openid_request ||= openid_server.decode_request(openid_params)
  end
  
  # Sets the current OpenID request and resets all dependent requests 
  def openid_request=(req)
    @openid_request, @sreg_request, @ax_fetch_request, @ax_store_request = req, nil, nil, nil
  end
  
  # SReg request reader
  def sreg_request
    @sreg_request ||= OpenID::SReg::Request.from_openid_request(openid_request)
  end
  
  # Attribute Exchange fetch request reader
  def ax_fetch_request
    @ax_fetch_request ||= OpenID::AX::FetchRequest.from_openid_request(openid_request)
  end

  # Attribute Exchange store request reader
  def ax_store_request
    @ax_store_request ||= OpenID::AX::StoreRequest.from_openid_request(openid_request)
  end

  # Adds SReg data (Hash) to an OpenID response.
  def add_sreg(resp, data)
    sreg_resp = OpenID::SReg::Response.extract_response(sreg_request, data)
    resp.add_extension(sreg_resp)
    resp
  end
  
  # Adds Attribute Exchange data (Hash) to an OpenID response. See:
  # http://rakuto.blogspot.com/2008/03/ruby-fetch-and-store-some-attributes.html
  def add_ax(resp, data)
    ax_resp = OpenID::AX::FetchResponse.new
    ax_args = data.reverse_merge('mode' => 'fetch_response')
    ax_resp.parse_extension_args(ax_args)
    resp.add_extension(ax_resp)
    resp
  end
  
  # Adds PAPE information for your server to an OpenID response.
  def add_pape(resp, policies = [], nist_auth_level = 0, auth_time = nil)
    if papereq = OpenID::PAPE::Request.from_openid_request(openid_request)
      paperesp = OpenID::PAPE::Response.new
      policies.each { |p| paperesp.add_policy_uri(p) }
      paperesp.nist_auth_level = nist_auth_level
      paperesp.auth_time = auth_time
      resp.add_extension(paperesp)
    end
    resp
  end
  
  # Answers check auth and associate requests.
  def handle_non_checkid_request
    resp = openid_server.handle_request(openid_request)
    render_openid_response(resp)
  end
  
  # Renders the final response output
  def render_openid_response(resp)
    signed_response = openid_server.signatory.sign(resp) if resp.needs_signing
    web_response = openid_server.encode_response(resp)
    case web_response.code
    when OpenID::Server::HTTP_OK then render(:text => web_response.body, :status => 200)
    when OpenID::Server::HTTP_REDIRECT then redirect_to(web_response.headers['location'])
    else render(:text => web_response.body, :status => 400)
    end   
  end

end