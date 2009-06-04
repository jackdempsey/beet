FileUtils.rm_r Dir.glob("public/javascripts/*.js")

run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.2.6.min.js > public/javascripts/jquery.js"
run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"

# Thanks to Chris Wanstrath and Doug Ramsay. The below will make it so that Rails recognizes form requests
file 'public/javascripts/application.js', <<-CODE
jQuery.ajaxSetup({
'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});
CODE
