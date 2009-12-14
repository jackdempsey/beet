gem 'warden', :version => '~> 0.6.5'
gem 'devise', :version => '~> 0.7.1'

rake 'gems:install'
generate "devise_install"
generate "devise User"
generate "devise_views"

append_file 'config/environments/development.rb', "\nconfig.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
append_file 'config/environment.rb', "\nDeviseMailer.sender = 'test@example.com'\n"
add_after 'config/routes.rb', '# map.root :controller => "welcome"', "\n  map.root :controller => 'home'\n"

rake "db:migrate"

file 'app/controllers/home_controller.rb' do
  %{
class HomeController < ApplicationController
  def index 
    render :text => "Welcome!"
  end
end
  }
end

