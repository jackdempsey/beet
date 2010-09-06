# this is designed for rails 3
gem 'devise', :version => '1.1.2'

generate "devise:install"
generate "devise User"
generate "devise:views"

rake "db:migrate"
