file 'app/views/layouts/application.html.erb' do
%{
DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  <title><%= project_name %></title>
  <%= stylesheet_link_tag 'blueprint' %>
</head>
<body>

<%= flash[:notice] %>

<%= yield %>

</body>
</html>
}
end
