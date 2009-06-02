reset_file_location = "http://developer.yahoo.com/yui/build/reset/reset.css"
unless File.exists?('public/stylesheets/reset.css')
  begin
    file "public/stylesheets/reset.css" do
      open(reset_file_location).read
    end
  rescue
    "Couldn't load #{reset_file_location}"
  end
end
