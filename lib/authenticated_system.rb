module AuthenticatedSystem
  protected
    # Returns true or false if the account is logged in.
    # Preloads @current_account with the account model if they're logged in.
    def logged_in?
      current_account != :false
    end

    # Accesses the current account from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_account
      @current_account ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
    end

    # Store the given account id in the session.
    def current_account=(new_account)
      session[:account_id] = (new_account.nil? || new_account.is_a?(Symbol)) ? nil : new_account.id
      @current_account = new_account || :false
    end

    # Check if the account is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the account
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_account.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the account is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to login_path
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location(url = request.request_uri)
      session[:return_to] = url
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_account and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_account, :logged_in?
    end

    # Called from #current_account.  First attempt to login by the account id stored in the session.
    def login_from_session
      self.current_account = Account.find(session[:account_id]) if session[:account_id]
    end

    # Called from #current_account.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |accountname, password|
        self.current_account = Account.authenticate(accountname, password)
      end
    end

    # Called from #current_account.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      account = cookies[:auth_token] && Account.find_by_remember_token(cookies[:auth_token])
      if account && account.remember_token?
        account.remember_me
        cookies[:auth_token] = { :value => account.remember_token, :expires => account.remember_token_expires_at }
        self.current_account = account
      end
    end
end
