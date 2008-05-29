class InfoController < ApplicationController

  # The yadis discovery header tells incoming OpenID
  # requests where to find the server endpoint.
  def index
    response.headers['X-XRDS-Location'] = formatted_server_url(:format => :xrds, :protocol => scheme)
  end

  # This page is to prevent phishing attacks. It should
  # not contain any links, the user has to navigate to
  # the right login page manually.
  def safe_login
    render :layout => false
  end

  def help
  end
  
end
