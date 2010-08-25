%w(application controls dragdrop effects prototype rails).each do |filename|
  FileUtils.rm("public/javascripts/#{filename}.js")
end

run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.4.1.min.js > public/javascripts/jquery.js"
run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"
run "curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js"

prepend_file 'public/javascripts/rails.js', %{jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");}})}
