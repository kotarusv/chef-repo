#
# Cookbook:: deployment
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


# copy java application war file to cookbook files folder.We can also deploy directly to 
# webapps folder
remote_file "#{node['deployment']['cookbook_path']}/files/#{node['deployment']['filename']}" do 
  source "#{node['deployment']['artifact_url']}/#{node['deployment']['filename']}"
  action :create
end

# Install/Deploy new configuration as part of application deployment
template "#{node['deployment']['tomcat_base']}/conf/server.xml" do
  source "server.xml.erb"
  variables(
    :server_port => node['deployment']['port']
)
  notifies :restart, "service[tomcat8]"
end

# Remove default ROOT folder  under webapps 
directory "#{node['deployment']['tomcat_base']}/webapps/ROOT" do
  action :delete
  recursive true
end

# Copy deployment artifact (war, ear) to deployment folder 
cookbook_file "#{node['deployment']['tomcat_base']}/webapps/#{node['deployment']['filename']}" do
  source "sample.war"
  mode "0644"
  user "tomcat"
  group "tomcat"
  notifies :restart, "service[tomcat8]"
end

service 'tomcat8' do
  supports :restart => true
end
