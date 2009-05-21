# app/models/user_session.rb
file "app/models/user_session.rb" do 
  %q{
    class UserSession < Authlogic::Session::Base
      # configuration here, see documentation for sub modules of Authlogic::Session
    end
  }
end
