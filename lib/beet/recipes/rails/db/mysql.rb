file 'config/database.yml' do
  %{  
# MySQL.  Versions 4.1 and 5.0 are recommended.
#
# Install the MySQL driver:
#   gem install mysql
# On Mac OS X:
#   sudo gem install mysql -- --with-mysql-dir=/usr/local/mysql
# On Mac OS X Leopard:
#   sudo env ARCHFLAGS="-arch i386" gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config
#       This sets the ARCHFLAGS environment variable to your native architecture
# On Windows:
#   gem install mysql
#       Choose the win32 build.
#       Install MySQL and put its /bin directory on your path.
#
# And be sure to use new-style password hashing:
#   http://dev.mysql.com/doc/refman/5.0/en/old-client.html
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
