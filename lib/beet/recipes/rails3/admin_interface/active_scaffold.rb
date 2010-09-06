# install plugins
#
plugin 'active_scaffold', :git => 'git://github.com/vhochstein/active_scaffold.git'
plugin 'verification', :git => 'git://github.com/rails/verification.git'
plugin 'render_component', :git => 'git://github.com/vhochstein/render_component.git'

# configure as much as we can automatically
add_after 'app/views/layouts/application.html.erb','  <%= csrf_meta_tag %>', '  <%= active_scaffold_includes %>'

