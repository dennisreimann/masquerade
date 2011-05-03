class AccountsController < ApplicationController
  
  before_filter :login_required, :except => [:show, :new, :create, :activate]
  before_filter :detect_xrds, :only => :show
  
  def show
    @account = Account.first(:conditions => ['login = ? AND enabled = ?', params[:account], true])
    raise ActiveRecord::RecordNotFound if @account.nil?
    
    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = identity_url(:account => @account, :format => :xrds, :protocol => scheme)
      end
      format.xrds
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
      redirect_to login_path, :notice => t(:thanks_for_signing_up_activation_link)
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
      redirect_to edit_account_path(:account => current_account), :notice => t(:profile_updated)
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
      redirect_to root_path, :notice => t(:account_disabled)
    else
      redirect_to edit_account_path, :alert => t(:entered_password_is_wrong)
    end
  end
  
  def activate
    begin
      account = Account.find_and_activate!(params[:id])
      redirect_to login_path, :notice => t(:account_activated_login_now)
    rescue ArgumentError, Account::ActivationCodeNotFound
      redirect_to new_account_path, :alert => t(:couldnt_find_account_with_code_create_new_one)
    rescue Account::AlreadyActivated
      redirect_to login_path, :alert => t(:account_already_activated_please_login)
    end
  end
  
  def change_password
    if Account.authenticate(current_account.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_account.password_confirmation = params[:password_confirmation]
        current_account.password = params[:password]        
        if current_account.save
          redirect_to edit_account_path(:account => current_account), :notice => t(:password_has_been_changed)
        else
          redirect_to edit_account_path, :alert => t(:sorry_password_couldnt_be_changed)
        end
      else
        @old_password = params[:old_password]
        redirect_to edit_account_path, :alert => t(:confirmation_of_new_password_invalid)
      end
    else
      redirect_to edit_account_path, :alert => t(:old_password_incorrect)
    end 
  end

  protected

  def detect_xrds
    if params[:account] =~ /\A(.+)\.xrds\z/
      request.format = :xrds
      params[:account] = $1
    end
  end
  
end
