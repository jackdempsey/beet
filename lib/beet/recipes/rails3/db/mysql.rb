gem "mysql"

run "bundle install"

file 'config/database.yml' do
  %{  
---
development: &defaults
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{project_name}_development
  pool: 5
  username: root
  password:
 
# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<:       *defaults
  database: #{project_name}_test
 
production:
  <<:       *defaults
  database: #{project_name}_production
}
end

FileUtils.copy "config/database.yml", "config/database.yml.example"

if yes?("Create databases using rake db:create:all?")
  rake "db:create:all"
end

