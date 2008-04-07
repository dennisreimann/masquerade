class InfoController < ApplicationController

  # The yadis discovery header tells incoming OpenID
  # requests where to find the server endpoint.
  def index
    response.headers['X-XRDS-Location'] = formatted_server_path(:xrds)
  end

  def help
  end
end
