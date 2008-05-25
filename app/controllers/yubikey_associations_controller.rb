class YubikeyAssociationsController < ApplicationController
  
  before_filter :login_required
    
  def create
    if verify_yubico_otp(params[:yubico_otp])
      current_account.yubico_identity = extract_yubico_identity_from_otp(params[:yubico_otp])
      current_account.save
      flash[:notice] = 'Your account has been associated with your Yubico identity.'
    else
      flash[:error] = 'Sorry, the given Yubico one time password is incorrect.'
    end
    respond_to do |format|
      format.html { redirect_to edit_account_path }
    end
  end
  
  def destroy
    current_account.yubico_identity = nil
    current_account.save
    flash[:notice] = 'Your account has been disassociate from the Yubico identity.'
    
    respond_to do |format|
      format.html { redirect_to edit_account_path }
    end
  end
  
end
