FileUtils.mkdir_p("public/stylesheets/blueprint")
%w(forms.css grid.css grid.png ie.css print.css reset.css typography.css).each do |file|
  run "curl -L http://github.com/joshuaclayton/blueprint-css/blob/master/blueprint/src/#{file} \
        > public/stylesheets/blueprint/#{file}"
end
