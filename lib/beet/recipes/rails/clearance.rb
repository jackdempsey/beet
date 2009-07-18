gem 'thoughtbot-clearance', :lib => 'clearance',:source  => 'http://gems.github.com', :version => '~> 0.6'
gem 'webrat'
gem 'cucumber'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => "http://gems.github.com"


rake "gems:install", :sudo => true
rake "gems:unpack"
rake "db:create:all"

generate "clearance"
generate "cucumber"
generate "clearance_features"
rake "db:migrate"

environment "HOST = 'localhost'", :env => "development"
environment "HOST = 'localhost'", :env => "test"
environment "DO_NOT_REPLY = \"donotreply@example.com\""
route "map.root :controller => 'sessions', :action => 'new'"

run "cp -fr vendor/gems/thoughtbot-clearance*/app/views app/"

