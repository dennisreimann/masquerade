class SessionsController < ApplicationController
  
  before_filter :login_required, :only => :destroy
  after_filter :set_login_cookie, :only => :create
  
  def new
  end

  def create
    if password_is_yubico_otp?(params[:password]) && verify_yubico_otp(params[:password])
      yi = extract_yubico_identity_from_otp(params[:password])
      self.current_account = Account.find_by_login_and_yubico_identity(params[:login], yi)
    else
      self.current_account = Account.authenticate(params[:login], params[:password])
    end
    if logged_in?
      flash[:notice] = 'You are now logged in.'
      redirect_after_login
    else
      flash[:error]  = 'The login is incorrect or your account is not activated, yet.'
      redirect_to :action => 'new'
    end
  end

  def destroy
    current_account.forget_me 
    cookies.delete :auth_token
    reset_session
    flash[:notice] = 'You are now logged out.'
    redirect_to home_path
  end
  
  private
  
  def set_login_cookie
    if logged_in? && params[:remember_me] == '1'
      self.current_account.remember_me
      cookies[:auth_token] = { 
        :value => self.current_account.remember_token,
        :expires => self.current_account.remember_token_expires_at }
    end
  end
  
  def redirect_after_login
    if return_to = session[:return_to]
      session[:return_to] = nil
      redirect_to return_to
    else
      redirect_to identifier(current_account)
    end
  end
  
  def password_is_yubico_otp?(password)
    password.length == 44
  end
end