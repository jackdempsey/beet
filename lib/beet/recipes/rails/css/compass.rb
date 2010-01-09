framework = ask "What framework would you like to use (default: blueprint)?"
framework = 'blueprint' if framework.blank?

in_root do
  if yes? "Install haml in vendor/plugins (hit 'n' if you use it as a gem)?"
    run 'haml --rails .'
  end
  run "compass --rails -f #{framework} ."
end

layout_file = <<-FILE
!!! XML
!!!
%html{:xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", :lang => "en"}
  %head
    %meta{'http-equiv' => "content-type", :content => "text/html;charset=UTF-8"}
    %title= @browser_title || 'Default Browser Title'
    = stylesheet_link_tag 'compiled/screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'compiled/print.css', :media => 'print'
    /[if IE]
      = stylesheet_link_tag 'compiled/ie.css', :media => 'screen, projection'
    = stylesheet_link_tag 'scaffold'
  %body
    #container
      %h1 Welcome to Compass
      = yield
FILE

gem 'compass'

unless File.exists?('app/views/layouts/application.html.haml')
  file 'app/views/layouts/application.html.haml', layout_file
  puts "We've added a simple layout for you as well which includes the css. Enjoy!"
end

