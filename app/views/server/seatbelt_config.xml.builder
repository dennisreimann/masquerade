xml.instruct!
xml.opConfig(:version => '1.0') do
	xml.configRevision('2008050101')
	xml.title(APP_CONFIG['name'])
	xml.serverIdentifier(endpoint_url)
	xml.opDomain(APP_CONFIG['host'])
	xml.opCertCommonName(APP_CONFIG['ssl_certificate_common_name']) if APP_CONFIG['use_ssl']
	xml.opCertSHA1Hash(APP_CONFIG['ssl_certificate_sha1']) if APP_CONFIG['use_ssl']
	xml.loginUrl(login_url)
	xml.welcomeUrl(home_url)
	xml.loginStateUrl(formatted_seatbelt_state_url(:xml))
end