class SessionsController < ApplicationController
  
  before_filter :login_required, :only => :destroy
  after_filter :set_login_cookie, :only => :create
  
  def new
  end

  def create
    self.current_account = Account.authenticate(params[:login], params[:password])
    if logged_in?
      flash[:notice] = t(:you_are_logged_in)
      redirect_after_login
    else
      flash[:error]  = t(:login_incorrect_or_account_not_yet_activated)
      redirect_to :action => 'new'
    end
  end

  def destroy
    current_account.forget_me 
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t(:you_are_now_logged_out)
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
  
end