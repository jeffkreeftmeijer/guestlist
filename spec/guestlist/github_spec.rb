require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Guestlist::Github do
  describe '.fetch' do
    before do
      @ok = File.read(
        File.expand_path(
          File.dirname(__FILE__) + '/../stubs/github_200.xml'
        )
      )
    end

    it 'should call to Github via HTTParty' do
      HTTParty.should_receive(:post).with(
        'http://github.com/api/v2/json/user/show/login',
        :query => {
          :login => 'login',
          :token => 't0k3n'
        }
      ).and_return(
        HTTParty::Response.new(
          Crack::JSON.parse(@ok), @ok, 200, 'message'
        )
      )

      Guestlist::Github.fetch('login', 't0k3n')
    end

    it 'should return a hash with user data' do
      HTTParty.stub!(:post).and_return(
        HTTParty::Response.new(
          Crack::JSON.parse(@ok), @ok, 200, 'message'
        )
      )

      result = Guestlist::Github.fetch('login', 't0k3n')
      result.should be_instance_of Hash
      result.length.should == 1
      result['user']['name'].should == 'Bob'
      result['user']['blog'].should == 'http://bobsblog.com'
    end

    it 'should return false when authentication fails' do
      HTTParty.stub!(:post).and_return(
        HTTParty::Response.new(
          {}, '', 401, 'message'
        )
      )

      Guestlist::Github.fetch('wronglogin', 't3k0n').should == false
    end

    it 'should raise an error when anything else happens' do
      HTTParty.stub!(:post).and_return(
        HTTParty::Response.new(
          {}, '', 500, 'message'
        )
      )

      lambda {
        Guestlist::Github.fetch('login', 't0k3n')
      }.should raise_error(Guestlist::Github::StatusError, 500)
    end
  end
end
