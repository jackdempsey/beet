# install plugins
#
plugin 'active_scaffold', :git => 'git://github.com/vhochstein/active_scaffold.git'

if yes?("Use jquery? (y/n):")
  generate "active_scaffold_setup jquery"
else
  generate "active_scaffold_setup"
end

