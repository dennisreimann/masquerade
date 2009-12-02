module AuthenticationBackend
  class LDAP < ActiveRecord::Base
    
    def self.authenticate(options)
      uid, password = options[:login], options[:password]
      account, ldap_conn = nil, LDAP::SSLConn.new(APP_CONFIG['ldap']['host'], APP_CONFIG['ldap']['port'], true)
      begin
        ldap_conn.bind(APP_CONFIG['ldap']['bind_dn'] % uid, password)
        ldap_conn.search("ou=People,#{APP_CONFIG['ldap']['base']}", LDAP::LDAP_SCOPE_SUBTREE, "(&(objectClass=posixAccount)(uid=#{uid}))") do |entry|
          account = Account.find_or_create_by_uid(entry['uid'].first)
        end
      rescue LDAP::ResultError
        account
      ensure
        ldap_conn.unbind
      end
      account
    end
    
  end
end