class AccountMailer < ActionMailer::Base
  
  default_url_options[:host] = APP_CONFIG['host']
  
  def signup_notification(account)
    setup_email(account)
    @subject = 'Please activate your account'
  end
  
  def forgot_password(account)
    setup_email(account)
    @subject = 'Your request for a new password'
  end
  
  protected
  
  def setup_email(account)
    @from           = APP_CONFIG['mailer']['from']
    @recipients     = account.email
    @sent_on        = Time.now
    @body[:account] = account
  end
end
