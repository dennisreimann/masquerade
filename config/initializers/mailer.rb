# Mailer
Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  :address => Masquerade::Application::Config['mailer']['address'],
  :domain => Masquerade::Application::Config['mailer']['domain'],
  :port => Masquerade::Application::Config['mailer']['port'],
  :user_name => Masquerade::Application::Config['mailer']['user_name'],
  :password => Masquerade::Application::Config['mailer']['password'],
  :authentication => Masquerade::Application::Config['mailer']['authentication'] }

ActionMailer::Base.default_url_options[:protocol] = Masquerade::Application::Config['use_ssl'] ? 'https' : 'http'
ActionMailer::Base.default_url_options[:host] = Masquerade::Application::Config['host']
