require 'fileutils'
require 'active_support/core_ext/string/inflections'

run "gem install thin" if `which thin` == ''
run "gem install jeweler" if `which jeweler` == ''
run "gem install sinatra" if `gem list sinatra | grep sinatra` == ''

name = ask "Project name: "
run "jeweler #{name}"

file "#{name}/bin/#{name}" do
%{
#!/usr/bin/env ruby

# #{name} command line interface script.
# Run #{name} -h to get more usage.
# inspired by Dave Hrycyszyn
# http://labs.headlondon.com/2010/07/skinny-daemons/

require File.expand_path(File.join(*%w[.. .. lib #{name}]), __FILE__)
require 'thin'

rackup_file = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib #{name} config.ru]))
 
argv = ARGV
argv << ["-R", rackup_file] unless ARGV.include?("-R")
argv << ["-p", "2003"] unless ARGV.include?("-p")
argv << ["-e", "production"] unless ARGV.include?("-e")
Thin::Runner.new(argv.flatten).run!
}
end

FileUtils.chmod 0755, "#{name}/bin/#{name}"

file "#{name}/lib/#{name}/config.ru" do
%{
require File.dirname(__FILE__) + '/../#{name}'
#{name.camelize}.run! :port => 2003
}
end

file "#{name}/lib/#{name}.rb" do
%{
require 'rubygems'
require 'sinatra/base'
 
class #{name.camelize} < Sinatra::Base
  # This can display a nice status message.
  #
  get "/" do
    "#{name.titleize} is up and running."
  end
 
  # This POST allows your other apps to control the service.
  # 
  post "/do-something/:great" do
    # something great could happen here
  end  
end 
}
end
