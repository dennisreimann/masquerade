class AccountObserver < ActiveRecord::Observer
  
  def after_create(account)
    if Masquerade::Application::Config['send_activation_mail']
      AccountMailer.signup_notification(account).deliver
    else
      account.send(:activate!)
    end
    account.personas.new(:title => "Standard").update_attribute(:deletable, false)
  end

  def after_save(account)
    AccountMailer.forgot_password(account).deliver if account.recently_forgot_password?
  end
  
end
