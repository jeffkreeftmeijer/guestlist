$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'guestlist'
require 'spec'
require 'spec/autorun'

require 'crack'

Spec::Runner.configure do |config|
end

class User
  include Guestlist

  def self.find_by_login(*args)
    return new
  end

  def self.create!(*args)
    return new
  end
  
  def encrypted_token
    Digest::SHA1.hexdigest('token')
  end
  
  def update_attributes(*args)
    return true
  end
end
