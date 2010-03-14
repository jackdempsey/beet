# this is designed for rails 3
gem 'warden', :version => '0.9.3'
gem 'devise', :version => '1.0.2'

rake 'gems:install'
generate "devise_install"
generate "devise User"
generate "devise_views"

add_after 'config/routes.rb', '# root :to => "welcome#index"', "\n  root :controller => 'home'\n"

rake "db:migrate"

file 'app/controllers/home_controller.rb' do
  %{class HomeController < ApplicationController
  def index 
    render :text => "Welcome from your HomeController!"
  end
end
  }
end

