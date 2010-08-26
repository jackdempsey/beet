gem_group :cucumber do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber', :version => '0.7.3'
  gem 'rspec-rails', :version => '~> 2.0.0.beta.19'
  gem 'spork'
  gem 'launchy'
end

run 'bundle install'

generate 'cucumber:skeleton --rspec --capybara'
