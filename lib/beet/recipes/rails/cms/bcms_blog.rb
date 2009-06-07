bcms_blog_code = ask "enter the path to the top level directory holding the bcms_blog module code [downloads by default]"

if bcms_blog_location.empty?
  git "clone git://github.com/browsermedia/browsercms_blog_module.git"
  bcms_blog_code = Dir.pwd
end

inside bcms_blog_code do
  system "gem build bcms_blog.gemspec"
  sudo "gem install bcsm_blog*.gem"
  FileUtils.rm(Dir.glob('*.gem'))
end

