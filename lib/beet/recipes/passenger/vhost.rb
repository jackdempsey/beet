file "#{project_name}.local.vhost.conf" do
  %{
<VirtualHost *:80>
ServerName #{project_name}.local
DocumentRoot "#{root}/public"
RackEnv development
<directory "#{root}/public">
  Order allow,deny
  Allow from all
</directory>
</VirtualHost>
}.strip
end
default_to = "/etc/apache2/passenger_pane_vhosts"
answer = ask "Where should we write out vhost config: [#{default_to} is default]"
filename = answer.empty? ? default_to : answer
sudo "mv ./#{project_name}.local.vhost.conf #{filename}"
