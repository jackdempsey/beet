gem 'warden', :version => '~> 0.5.1'
gem 'devise', :version => '~> 0.4.1'

generate "devise_install"
generate "devise User"
generate "devise_views"

append_file 'config/environments/development.rb', "\nconfig.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
append_file 'config/environment.rb', "\nDeviseMailer.sender = 'test@example.com'\n"
add_after 'config/routes.rb', '# map.root :controller => "welcome"', "\nmap.root :controller => 'home'\n"

rake "db:migrate"
