gem 'rspec-rails', :version => '~> 2.0.0.beta.19', :group => [:development,:test]

run "bundle install"

generate "rspec:install"

puts %{
Make sure to change test_framework to :rspec inside config/application.rb:

    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end
}
