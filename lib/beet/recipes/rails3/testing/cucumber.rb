gem 'capybara', :group => :cucumber

gem 'database_cleaner', :group => :cucumber
gem 'cucumber-rails', :group => :cucumber
gem 'cucumber', :group => :cucumber, :version => '0.7.3'
gem 'rspec-rails', :group => :cucumber, :version => '~> 2.0.0.beta.19'
gem 'spork', :group => :cucumber
gem 'launchy', :group => :cucumber

run 'bundle install'

generate 'cucumber:skeleton --rspec --capybara'
