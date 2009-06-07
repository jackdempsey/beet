# install the gem
if `gem list bcms_blog | grep bcms_blog`.empty?
  # Run this inside or outside your bcms_blog directory, otherwise download the code
  git "clone git://github.com/browsermedia/bcms_blog.git" unless File.exists?('./bcms_blog') || File.basename(Dir.pwd) == 'bcms_blog'
  FileUtils.chdir 'bcms_blog' do
    system "gem build *.gemspec"
    sudo "gem install bcms_blog*.gem"
  end
  if yes? "Should I delete bcms_blog/"
    FileUtils.rm_rf('bcms_blog')
  end
end

# add to project
add_after 'config/environment.rb', "config.gem 'browsercms'" do
  "\tconfig.gem 'bcms_blog'"
end

add_before 'config/routes.rb', 'map.routes_for_browser_cms' do
  "map.routes_for_bcms_blog"
end
