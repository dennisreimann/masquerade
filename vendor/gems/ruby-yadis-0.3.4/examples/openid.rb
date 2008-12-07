# example of finding an OpenID server using YADIS

require 'yadis'

# Want to verify server certificates for https?
# Visit http://curl.haxx.se/docs/caextract.html and uncomment:
# YADIS.ca_path = '/path/to/cacert.pem'

url = 'http://brianellin.com/'
puts "Looking for servers for #{url}\n"

yadis = YADIS.discover(url)
openid_filter = Proc.new do |service|
  service.service_types.member?('http://openid.net/signon/1.0') ? service : nil
end

if yadis.nil?
  puts 'No XRDS found.'
else
  services = yadis.filter_services(openid_filter)
  if services.length > 0
    services.each {|s| puts "OpenID server found: #{s.uri}"}
  else
    puts 'No OpenID servers found.'  
  end
end

