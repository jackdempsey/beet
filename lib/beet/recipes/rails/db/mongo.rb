# based on jnunemaker's gist at http://gist.github.com/232953
file 'config/database.yml' do
  %{
development: &global_settings
    database: #{project_name}_development
    host: 127.0.0.1
    port: 27017
   
test:
  database: #{project_name}_test
  <<: *global_settings
 
production:
  host: hostname
  database: databasename
  username: username
  password: password
  <<: *global_settings
}
end

file 'config/initializers/mongo.rb' do
%{
config = YAML.load_file(Rails.root + 'config' + 'database.yml')[Rails.env]
 
MongoMapper.connection = Mongo::Connection.new(config['host'], config['port'], {
  :logger => Rails.logger
})
 
MongoMapper.database = config['database']
if config['username'].present?
  MongoMapper.database.authenticate(config['username'], config['password'])
end
 
Dir[Rails.root + 'app/models/**/*.rb'].each do |model_path|
  File.basename(model_path, '.rb').classify.constantize
end
MongoMapper.ensure_indexes!
 
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # if using older than 0.6.5 of MM then you want database instead of connection
    # MongoMapper.database.connect_to_master if forked
    MongoMapper.connection.connect_to_master if forked
  end
end
}
end

# for those who don't like keeping database.yml in version control
# we slot in an example file to serve as reference

FileUtils.copy "config/database.yml", "config/database.yml.example"

environment 'config.frameworks -= [:active_record]'

gem 'mongo_mapper'
