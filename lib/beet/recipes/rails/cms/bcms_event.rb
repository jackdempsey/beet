# install the gem
if `gem list bcms_event | grep bcms_event`.empty?
  # Run this inside or outside your bcms_event directory, otherwise download the code
  git "clone git://github.com/browsermedia/bcms_event.git" unless File.exists?('./bcms_event') || File.basename(Dir.pwd) == 'bcms_event'
  FileUtils.chdir 'bcms_event' do
    system "gem build *.gemspec"
    sudo "gem install bcms_event*.gem"
  end
  if yes? "Should I delete bcms_event/"
    FileUtils.rm_rf('bcms_event')
  end
end

# add to project
add_after 'config/environment.rb', "config.gem 'browsercms'" do
  "\tconfig.gem 'bcms_event'"
end

add_before 'config/routes.rb', 'map.routes_for_browser_cms' do
  "\tmap.routes_for_bcms_event\n"
end

run "rake db:migrate"
