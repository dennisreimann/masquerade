class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  include OpenidServerSystem
  include AuthenticatedSystem
  
  rescue_from(
    ActiveRecord::RecordNotFound,
    ActionController::RoutingError,
    ActionController::UnknownAction, :with => :render_404)
  rescue_from OpenID::Server::ProtocolError, :with => :render_500
  
  protect_from_forgery
  
  helper_method :identifier, :extract_login_from_identifier, :checkid_request
  
  protected
  
  # before_filter for every account-based controller
  def find_account
    @account = current_account
  end
  
  def render_404(exception)
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
  end
  
  def render_500
    render :file => "#{RAILS_ROOT}/public/500.html", :status => 500
  end
  
  # Returns the OpenID identifier for an account
  def identifier(account)
    identity_url(:account => account, :protocol => protocol_scheme)
  end
  
  def extract_login_from_identifier(openid_url)
    openid_url.gsub(identifier(''), '')
  end
  
  def checkid_request
    unless @checkid_request
      req_params = OpenIdRequest.find_by_token(session[:request_token]).parameters if session[:request_token]
      req = openid_server.decode_request(req_params) if req_params
      @checkid_request = req.is_a?(OpenID::Server::CheckIDRequest) ? req : false
    else
      @checkid_request
    end
  end
  
  private
  
  def protocol_scheme
    APP_CONFIG['use_ssl'] ? 'https' : 'http'
  end
  
end
