class YubikeyAssociationsController < ApplicationController
  
  before_filter :login_required
    
  def create
    if current_account.associate_with_yubikey(params[:yubico_otp])
      flash[:notice] = t(:account_associated_with_yubico_identity)
    else
      flash[:error] = t(:sorry_yubico_one_time_password_incorrect)
    end
    respond_to do |format|
      format.html { redirect_to edit_account_path }
    end
  end
  
  def destroy
    current_account.yubico_identity = nil
    current_account.save
    flash[:notice] = t(:account_disassociated_from_yubico_identity)
    
    respond_to do |format|
      format.html { redirect_to edit_account_path }
    end
  end
  
end
