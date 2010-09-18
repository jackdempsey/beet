gem 'devise'
gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git'

run "bundle update"

generate "rails_admin:install_admin"
