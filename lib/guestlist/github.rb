require 'rubygems'
require 'httparty'

module Guestlist
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
