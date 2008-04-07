class AccountObserver < ActiveRecord::Observer
  
  def after_create(account)
    AccountMailer.deliver_signup_notification(account)
  end

  def after_save(account)
    account.personas.new(:title => "Standard").update_attribute(:deletable, false) if account.pending?
    AccountMailer.deliver_forgot_password(account) if account.recently_forgot_password?
  end
  
end
