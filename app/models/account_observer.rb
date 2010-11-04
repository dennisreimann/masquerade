class AccountObserver < ActiveRecord::Observer
  
  def after_create(account)
    AccountMailer.signup_notification(account).deliver
  end

  def after_save(account)
    account.personas.new(:title => "Standard").update_attribute(:deletable, false) if account.pending?
    AccountMailer.forgot_password(account).deliver if account.recently_forgot_password?
  end
  
end
