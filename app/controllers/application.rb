class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  include OpenidServerSystem
  include AuthenticatedSystem
  
  protect_from_forgery
  
  filter_parameter_logging :password, :token
  
  rescue_from(
    ActiveRecord::RecordNotFound,
    ActionController::UnknownAction, :with => :render_404)
  rescue_from ActionController::InvalidAuthenticityToken, :with => :render_422
  
  helper_method :extract_host, :extract_login_from_identifier, :checkid_request,
    :identifier, :endpoint_url, :scheme
  
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
  
  # Extracts the hostname from the given url, which is used to
  # display the name of the requesting website to the user
  def extract_host(u)
    URI.split(u).compact[1]
  end
  
  def extract_login_from_identifier(openid_url)
    openid_url.gsub(identifier(''), '')
  end
  
  def checkid_request
    unless @checkid_request
      req = openid_server.decode_request(current_openid_request.parameters) if current_openid_request
      @checkid_request = req.is_a?(OpenID::Server::CheckIDRequest) ? req : false
    end
    @checkid_request
  end
  
  def current_openid_request
    @current_openid_request ||= OpenIdRequest.find_by_token(session[:request_token]) if session[:request_token]
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
