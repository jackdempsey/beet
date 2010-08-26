gem 'rspec-rails', :version => '~> 2.0.0.beta.19', :group => [:development,:test]

run "bundle install"

generate "rspec:install"

in_root do
  add_after 'config/application.rb', 'class Application < Rails::Application' do
%{
    config.generators do |g|
      g.test_framework :rspec
    end
}
  end
end
