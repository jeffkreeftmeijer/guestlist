require 'rubygems'
require 'httparty'

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

  class Github
    class StatusError < StandardError; end

    def self.fetch(login, token)
      response = HTTParty.post(
        "http://github.com/api/v2/json/user/show/#{login}",
        {
          :query => {
            :login => login,
            :token => token
          }
        }
      )

      case response.code
        when 200; response
        when 401; false
        else; raise StatusError, response.code
      end
    end
  end
end
