if ExceptionNotifier
  Masquerade::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[#{Masquerade::Application::Config['name']} Error] ",
    :sender_address => %("#{Masquerade::Application::Config['name']}" <#{Masquerade::Application::Config['mailer']['from']}>),
    :exception_recipients => [Masquerade::Application::Config['email']]
end
