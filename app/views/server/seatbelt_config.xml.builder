xml.instruct!
xml.opConfig(:version => '1.0') do
	xml.configRevision('2008050101')
	xml.title(APP_CONFIG['name'])
	xml.serverIdentifier(endpoint_url)
	xml.opDomain(APP_CONFIG['host'])
	xml.opCertCommonName(APP_CONFIG['ssl_certificate_common_name']) if APP_CONFIG['use_ssl']
	xml.opCertSHA1Hash(APP_CONFIG['ssl_certificate_sha1']) if APP_CONFIG['use_ssl']
	xml.loginUrl(login_url(:protocol => scheme))
	xml.welcomeUrl(home_url(:protocol => scheme))
	xml.loginStateUrl(formatted_seatbelt_state_url(:protocol => scheme, :format => :xml))
	xml.toolbarGrayBackground('#e0e0e0')
  xml.toolbarGrayBorder('#a0a0a0')
  xml.toolbarGrayText('#505050')
  xml.toolbarLoginBackground('#a7e0fb')
  xml.toolbarLoginBorder('#a0a0a0')
  xml.toolbarLoginText('#000000')
  xml.toolbarHighBackground('#f2db8b')
  xml.toolbarHighBorder('#22ab1b')
  xml.toolbarHighText('#22ab1b')
end