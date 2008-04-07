module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(account)
    @request.session[:account_id] = account ? accounts(account).id : nil
  end

  def authorize_as(account)
    if @request.env["HTTP_AUTHORIZATION"] = account
      ActionController::HttpAuthentication::Basic.encode_credentials(accounts(account).login, 'test')
    else
      nil
    end
  end
end
