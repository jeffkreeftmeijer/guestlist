require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Guestlist do
  before do
    @github_200 = Crack::JSON.parse(
      File.read(
        File.expand_path(
          File.dirname(__FILE__) + '/stubs/github_200.xml'
        )
      )
    )
  end
  describe '#authenticate' do
    it 'should call find with the login' do
      User.should_receive(:find_by_login).with('login')
      User.authenticate('login', 'token')
    end

    describe 'when authenticating an existing user' do
      describe 'with the correct token' do
        it 'should return the user' do
          User.authenticate('exists', 'token').should be_instance_of User
        end

        it 'should not try to fetch the user' do
          Guestlist::Github.should_not_receive(:fetch)
          User.authenticate('exists', 'token')
        end

        it 'should not create a new user' do
          User.should_not_receive(:create!)
          User.authenticate('exists', 'token')
        end
      end
      
      describe 'with an incorrect token' do
        it 'should not return the user' do
          User.authenticate('exists', 'wrongtoken').should == nil
        end
        
        it 'should try to fetch the user' do
          Guestlist::Github.should_receive(:fetch).with('exists', 'wrongtoken')
          User.authenticate('exists', 'wrongtoken')
        end
        
        describe 'that seems to be correct after all' do
          before do
            Guestlist::Github.stub!(:fetch).and_return(@github_200)
          end
          
          it 'should return the user' do
            User.authenticate('exists', 'wrongtoken').should be_instance_of User
          end
          
          it 'should not create a new user' do
            User.should_not_receive(:create!)
            User.authenticate('exists', 'wrongtoken')
          end

          it 'should update the user token' do
            user = User.new
            User.stub(:find_by_login).and_return(user)
            user.should_receive(:update_attributes)
            @user = User.authenticate('exists', 'wrongtoken')
          end
        end
      end
    end

    describe 'when authenticating a user that does not exist yet' do
      before do
        User.stub(:find_by_login).and_return(nil)
        Guestlist::Github.stub!(:fetch).and_return(@github_200)
      end

      it 'should try to fetch the user' do
        Guestlist::Github.should_receive(:fetch).with('doesnt_exist_yet', 'token')
        User.authenticate('doesnt_exist_yet', 'token')
      end

      it 'should create a new user' do
        User.should_receive(:create!).with({
          :login =>           'doesnt_exist_yet',
          :encrypted_token => 'ee977806d7286510da8b9a7492ba58e2484c0ecc'
        })
        User.authenticate('doesnt_exist_yet', 'token')
      end
    end

    describe 'when authenticating a user that does not exist' do
      before do
        User.stub(:find_by_login).and_return(nil)
        Guestlist::Github.stub!(:fetch).and_return(false)
      end
      it 'should return nil' do
        User.should_receive(:find_by_login).and_return(nil)
        User.authenticate('doesnt_exist', 'token').should == nil
      end

      it 'should try to fetch the user' do
        Guestlist::Github.should_receive(:fetch).with('doesnt_exist', 'token')
        User.authenticate('doesnt_exist', 'token')
      end

      it 'should not create a new user' do
        User.should_not_receive(:create!)
        User.authenticate('doesnt_exist', 'token')
      end
    end
  end
end
