gem 'cucumber'
require 'cucumber'
gem 'rspec'
require 'spec'

Before do
  @tmp_root = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end

After do
  unless ENV['LEAVE_CUCUMBER_GENERATED_OUTPUT']
    FileUtils.rm_rf @active_project_folder
  end
end

gem "fakeweb"
require "fakeweb"

Before do
  FakeWeb.allow_net_connect = false
end
