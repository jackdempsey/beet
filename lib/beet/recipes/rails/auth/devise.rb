gem 'warden', :version => '0.9.3'
gem 'devise', :version => '1.0.2'

rake 'gems:install'
generate "devise_install"
generate "devise User"
generate "devise_views"

append_file 'config/environments/development.rb', "\nconfig.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
add_after 'config/routes.rb', '# map.root :controller => "welcome"', "\n  map.root :controller => 'home'\n"

rake "db:migrate"

file 'app/controllers/home_controller.rb' do
  %{class HomeController < ApplicationController
  def index 
    render :text => "Welcome from your HomeController!"
  end
end
  }
end

