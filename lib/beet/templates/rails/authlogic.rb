file "app/models/user_session.rb" do 
  %{
class UserSession < Authlogic::Session::Base
  logout_on_timeout true # default is false
end
}
end

file "app/models/user.rb" do
  %{
class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.logged_in_timeout = 10.minutes # default is 10.minutes
  end
end
}
end

file "app/controllers/user_sessions_controller.rb" do
  %{
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end
}
end


file "app/views/user_sessions/new.html.erb" do
    %{
<h1>Login</h1>

<% form_for @user_session, :url => user_session_path do |f| %>
  <%= f.error_messages %>
  <%= f.label :email %><br />
  <%= f.text_field :email %><br />
  <br />
  <%= f.label :password %><br />
  <%= f.password_field :password %><br />
  <br />
  <%= f.check_box :remember_me %><%= f.label :remember_me %><br />
  <br />
  <%= f.submit "Login" %>
<% end %>
}
end


route 'map.resource :user_session'

file "app/controllers/application.rb" do
  %{
  class ApplicationController < ActionController::Base
    filter_parameter_logging :password, :password_confirmation
    helper_method :current_user_session, :current_user

    private
      def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.user
      end
  end
}
end

file "app/controllers/users_controller.rb" do
  %{
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
  end
 
  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
}
end

file "app/views/users/_form.html.erb" do
    %{
<%= form.label :email %><br />
<%= form.text_field :email %><br />
<br />
<%= form.label :password, form.object.new_record? ? nil : "Change password" %><br />
<%= form.password_field :password %><br />
<br />
<%= form.label :password_confirmation %><br />
<%= form.password_field :password_confirmation %><br />
}
end

file "app/views/users/edit.html.erb" do
    %{
<h1>Edit My Account</h1>
 
<% form_for @user, :url => account_path do |f| %>
  <%= f.error_messages %>
  <%= render :partial => "form", :object => f %>
  <%= f.submit "Update" %>
<% end %>
 
<br /><%= link_to "My Profile", account_path %>
}
end

file "app/views/users/new.html.erb" do
    %{
<h1>Register</h1>
 
<% form_for @user, :url => account_path do |f| %>
  <%= f.error_messages %>
  <%= render :partial => "form", :object => f %>
  <%= f.submit "Register" %>
<% end %>
}
end

file "app/views/users/show.html.erb" do
    %{
<p>
  <b>Email:</b>
  <%=h @user.email %>
</p>
 
<p>
  <b>Login count:</b>
  <%=h @user.login_count %>
</p>
 
<p>
  <b>Last request at:</b>
  <%=h @user.last_request_at %>
</p>
 
<p>
  <b>Last login at:</b>
  <%=h @user.last_login_at %>
</p>
 
<p>
  <b>Current login at:</b>
  <%=h @user.current_login_at %>
</p>
 
<p>
  <b>Last login ip:</b>
  <%=h @user.last_login_ip %>
</p>
 
<p>
  <b>Current login ip:</b>
  <%=h @user.current_login_ip %>
</p>
 
 
<%= link_to 'Edit', edit_account_path %>
}
end

# can't rely on internal rails migration generation, so we do it this way
run "script/generate migration beet_authlogic_create_user"

#now open it
file(Dir.glob('db/migrate/*beet_authlogic_create_user*').first) do
  %{
class BeetAuthlogicCreateUser < ActiveRecord::Migration
  def self.up
    unless table_exists?(:users)
      create_table :users do |t|
        t.string    :email,               :null => false                # optional, you can use login instead, or both
        t.string    :crypted_password,    :null => false                # optional, see below
        t.string    :password_salt,       :null => false                # optional, but highly recommended
        t.string    :persistence_token,   :null => false                # required
        t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
        t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

        # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
        t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
        t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
        t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
        t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
        t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
        t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
        t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns
      end
    end
  end

  def self.down
    drop_table :users
  end
end
}
end

gem 'authlogic'

rake "gems:install", :sudo => true
rake "db:create:all" 
rake "db:migrate"
