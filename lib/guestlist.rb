require 'guestlist/github'

module Guestlist
  module ClassMethods
    def authenticate(login, token)
      attributes = {:login => login, :encrypted_token => encrypt(token)}

      if user = find_by_login(login)
        return user if user.encrypted_token == attributes[:encrypted_token]
      end

      if Github.fetch(login, token)
        user.update_attributes(attributes) if user
        user || User.create!(attributes)
      end
    end

    protected

    def encrypt(string)
      Digest::SHA1.hexdigest(string)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
