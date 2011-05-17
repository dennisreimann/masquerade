xml.instruct!
xml.opConfig(:version => '1.0', :serverIdentifier => endpoint_url) do
	xml.configRevision('2008090801')
	xml.title(Masquerade::Application::Config['name'])
	xml.serverIdentifier(endpoint_url)
	xml.opDomain(Masquerade::Application::Config['host'])
	xml.opCertCommonName(Masquerade::Application::Config['ssl_certificate_common_name']) if Masquerade::Application::Config['use_ssl']
	xml.opCertSHA1Hash(Masquerade::Application::Config['ssl_certificate_sha1']) if Masquerade::Application::Config['use_ssl']
	xml.loginUrl(login_url(:protocol => scheme))
	xml.welcomeUrl(root_url(:protocol => scheme))
	xml.loginStateUrl(seatbelt_state_url(:protocol => scheme, :format => :xml))
	xml.settingsIconUrl("#{root_url(:protocol => scheme)}images/seatbelt_icon.png")
	xml.toolbarGrayIconUrl("#{root_url(:protocol => scheme)}images/seatbelt_icon_gray.png")
	xml.toolbarHighIconUrl("#{root_url(:protocol => scheme)}images/seatbelt_icon_high.png")
	xml.toolbarGrayBackground('#EBEBEB')
  xml.toolbarGrayBorder('#666666')
  xml.toolbarGrayText('#666666')
  xml.toolbarLoginBackground('#EBEBEB')
  xml.toolbarLoginBorder('#2B802B')
  xml.toolbarLoginText('#2B802B')
  xml.toolbarHighBackground('#EBEBEB')
  xml.toolbarHighBorder('#F50012')
  xml.toolbarHighText('#F50012')
end
