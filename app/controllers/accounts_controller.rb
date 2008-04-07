class AccountsController < ApplicationController
  
  before_filter :login_required, :except => [:show, :new, :create, :activate]
  
  def show
    @account = Account.find_by_login(params[:account])
    
    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = formatted_identity_path(@account, :xrds)
      end
      format.xrds do
        @types = [ OpenID::OPENID_2_0_TYPE, OpenID::OPENID_1_0_TYPE, OpenID::SREG_URI ]
        render :template => 'server/index'
      end
    end
  end
  
  def new
    @account = Account.new
  end

  def create
    cookies.delete :auth_token
    @account = Account.new(params[:account])
    begin
      @account.save!
      flash[:notice] = 'Thank you for signing up! We sent you an email containing an activation link.'
      redirect_to login_path    
    rescue ActiveRecord::RecordInvalid
      render :action => 'new'
    end
  end

  def edit
    @account = current_account
  end

  def update
    @account = current_account
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Your profile has been updated.'
      redirect_to edit_account_path(:account => current_account)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @account = current_account
    if @account.authenticated?(params[:confirmation_password])
      @account.disable!
      current_account.forget_me 
      cookies.delete :auth_token
      reset_session
      flash[:notice] = 'Your account has been disabled.'
      redirect_to home_path
    else
      flash[:error] = 'The entered password is wrong.'
      redirect_to edit_account_path
    end
  end
  
  def activate
    begin
      account = Account.find_and_activate!(params[:id])
      flash[:notice] = 'Your account is activated - you can login now.'
      redirect_to login_path
    rescue Account::ArgumentError, Account::ActivationCodeNotFound
      flash[:error] = 'We could not find any account with the given activation code. Please create a new account.'
      redirect_to new_account_path
    rescue Account::AlreadyActivated
      flash[:error] = 'Your account is already activated - please login.'
      redirect_to login_path
    end
  end
  
  def change_password
    if Account.authenticate(current_account.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_account.password_confirmation = params[:password_confirmation]
        current_account.password = params[:password]        
        if current_account.save
          flash[:notice] = 'Your password has been changed.'
          redirect_to edit_account_path(:account => current_account)
        else
          flash[:error] = 'Sorry, your password could not be changed.'
          redirect_to edit_account_path
        end
      else
        flash[:error] = 'The confirmation of the new password was incorrect.'
        @old_password = params[:old_password]
        redirect_to edit_account_path
      end
    else
      flash[:error] = 'Your old password is incorrect.'
      redirect_to edit_account_path
    end 
  end
  
end