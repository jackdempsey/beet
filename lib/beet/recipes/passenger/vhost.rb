in_root do
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
  run "sudo mv ./#{project_name}.local.vhost.conf /etc/apache2/passenger_pane_vhosts"
end
