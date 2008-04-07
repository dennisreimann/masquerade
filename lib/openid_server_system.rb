# This module is mainly a wrapper for the OpenID::Server functionality provided
# by the ruby-openid gem. Included in your server controller it gives you some
# helpful methods to access and answer OpenID requests.
module OpenidServerSystem
  
  protected
  
  # OpenID store accessor, used inside this module 
  # to procide access to the storage machanism
  def openid_store
    @openid_store ||= ActiveRecordStore.new
  end
  
  # OpenID server accessor, use this to access the server 
  # functionality from inside your server controller
  def openid_server
    @openid_server ||= OpenID::Server::Server.new(openid_store, server_url)
  end
  
  # OpenID parameter accessor, use this to access only OpenID 
  # request parameters from inside your server controller
  def openid_params
    @openid_params ||= params.clone.delete_if { |k,v| k.index('openid.') != 0 }
  end

  # OpenID request accessor
  def openid_request
    @openid_request ||= openid_server.decode_request(openid_params)
  end
  
  def openid_request=(req)
    @openid_request = req
  end
  
  # SReg request accessor
  def sreg_request
    @sreg_request ||= OpenID::SReg::Request.from_openid_request(openid_request)
  end
  
  # Returns an array with the required SReg fields, e.g. ['nickname', 'email']
  def required_sreg_fields
    @required_sreg_fields ||= sreg_request ? sreg_request.required : []
  end 
  
  # Returns an array with the optional SReg fields, e.g. ['fullname', 'dob']
  def optional_sreg_fields
    @optional_sreg_fields ||= sreg_request ? sreg_request.optional : []
  end

  # Adds SReg data (Hash) to an OpenID response.
  def add_sreg(req, resp, sreg_data)
    if sregreq = OpenID::SReg::Request.from_openid_request(req)
      sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
      resp.add_extension(sregresp)
    end
    resp
  end
  
  # Adds PAPE information for your server to an OpenID response.
  # Currently there is no auth level implemented.
  # TODO: Implement PAPE
  def add_pape(req, resp)
    if papereq = OpenID::PAPE::Request.from_openid_request(req)
      paperesp = OpenID::PAPE::Response.new
      paperesp.nist_auth_level = 0
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