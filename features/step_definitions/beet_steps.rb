Then /^"(.*)" should be a rails app$/ do |directory|
  File.exists?(File.join(@active_project_folder, 'app'))
  File.exists?(File.join(@active_project_folder, 'config'))
  File.exists?(File.join(@active_project_folder, 'db'))
  File.exists?(File.join(@active_project_folder, 'public'))
  File.exists?(File.join(@active_project_folder, 'vendor'))
end
