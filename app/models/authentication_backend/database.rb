module AuthenticationBackend
  class Database < ActiveRecord::Base
    
    def self.authenticate(options)
      if a = Account.find(:first, :conditions => ['login = ? and enabled = ? and activated_at IS NOT NULL', options[:login], true]) # need to get the salt
        if a.authenticated?(options[:password])
          a.last_authenticated_at, a.last_authenticated_with_yubikey = Time.now, a.authenticated_with_yubikey?
          a.save(false)
          a
        end
      end
    end
    
  end
end