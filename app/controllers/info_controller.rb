class InfoController < ApplicationController

  # The yadis discovery header tells incoming OpenID
  # requests where to find the server endpoint.
  def index
    response.headers['X-XRDS-Location'] = server_url(:format => :xrds, :protocol => scheme)
  end

  def help
  end
  
end
