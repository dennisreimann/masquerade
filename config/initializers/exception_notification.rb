ExceptionNotifier.exception_recipients = [APP_CONFIG['email']]
ExceptionNotifier.sender_address = %("#{APP_CONFIG['name']}" <#{APP_CONFIG['mailer']['from']}>)
ExceptionNotifier.email_prefix = "[#{APP_CONFIG['name']} Error] "

# Email notifications will only occur when the IP address is determined not to
# be local. You can specify certain addresses to always be local so that you'll
# get a detailed error instead of the generic error page. You do this in your
# controller (or even per-controller):
# consider_local "64.72.18.143", "14.17.21.25"

# The address "127.0.0.1" is always considered local. If you want to completely
# reset the list of all addresses (for instance, if you wanted "127.0.0.1" to
# NOT be considered local), you can simply do, somewhere in your controller:
# local_addresses.clear