gem 'warden', :version => '~> 0.5.1'
gem 'devise', :version => '~> 0.4.1'

generate "devise_install"

generate "devise User"

generate "devise_views"

add_after 'config/environments/development.rb', 'config.action_mailer.raise_delivery_errors', "config.action_mailer.default_url_options = { :host => 'localhost:3000' }"

rake "db:migrate"
