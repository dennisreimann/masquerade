class AccountObserver < ActiveRecord::Observer
  
  def after_create(account)
    if Masquerade::Application::Config['send_activation_mail']
      AccountMailer.signup_notification(account).deliver
    else
      account.send(:activate!)
    end
    account.public_persona = account.personas.build(:title => "Standard")
    account.public_persona.deletable = false
    account.save!
  end

  def after_save(account)
    AccountMailer.forgot_password(account).deliver if account.recently_forgot_password?
  end
  
end
