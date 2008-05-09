class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  include OpenidServerSystem
  include AuthenticatedSystem
  
  protect_from_forgery
  
  rescue_from(
    ActiveRecord::RecordNotFound,
    ActionController::UnknownAction, :with => :render_404)
  rescue_from ActionController::InvalidAuthenticityToken, :with => :render_422
  
  helper_method :extract_login_from_identifier, :checkid_request, :identifier, :endpoint_url, :scheme
  
  protected
  
  # before_filter for every account-based controller
  def find_account
    @account = current_account
  end
  
  def endpoint_url
    server_url(:protocol => scheme)
  end
  
  # Returns the OpenID identifier for an account
  def identifier(account)
    identity_url(:account => account, :protocol => scheme)
  end
  
  def extract_login_from_identifier(openid_url)
    openid_url.gsub(identifier(''), '')
  end
  
  def checkid_request
    unless @checkid_request
      oid_request = OpenIdRequest.find_by_token(session[:request_token]) if session[:request_token]
      req = openid_server.decode_request(oid_request.parameters) if oid_request
      @checkid_request = req.is_a?(OpenID::Server::CheckIDRequest) ? req : false
    else
      @checkid_request
    end
  end
  
  def render_404
    render_error(404)
  end
  
  def render_422
    render_error(422)
  end
  
  def render_500
    render_error(500)
  end
  
  def render_error(status_code)
    render :file => "#{RAILS_ROOT}/public/#{status_code}.html", :status => status_code
  end
  
  private
  
  def scheme
    APP_CONFIG['use_ssl'] ? 'https' : 'http'
  end
  
end
