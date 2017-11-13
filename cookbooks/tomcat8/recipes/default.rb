#
# Cookbook:: tomcat8
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# create a group to run tocat process
group node['tomcat8']['group']

# create a user to run tomcat process
user node['tomcat8']['user'] do
  comment 'tomcat user'
  uid node['tomcat8']['tomcat_uid']
  gid node['tomcat8']['group']
  home node['tomcat8']['tomcat_home']
  shell '/bin/false'
end

# download tomcat binary to /tmp folder for extraction 
remote_file "/tmp/apache-tomcat-#{node['tomcat8']['tomcat_version']}.tar.gz" do
  source "http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v#{node['tomcat8']['tomcat_version']}/bin/apache-tomcat-#{node['tomcat8']['tomcat_version']}.tar.gz"
  owner node['tomcat8']['user']
  group node['tomcat8']['group']
  mode '0755'
  action :create
end

# create tomcat base folder under /opt/tomcat 
directory "#{node['tomcat8']['tomcat_base']}" do
  owner node['tomcat8']['user']
  group node['tomcat8']['group']
  mode '0755'
  action :create
end

# unzip/extract tomcat binary to tomcat base 
execute "extract tomcat #{node['tomcat8']['tomcat_version']}.tar.gz filer" do
  command "tar xzvf apache-tomcat-8*tar.gz -C #{node['tomcat8']['tomcat_base']} --strip-components=1"
  cwd "#{node['tomcat8']['tmp_path']}"
end

# delete tomcat binary from /tmp folder after extraction 
file "#{node['tomcat8']['tmp_path']}/apache-tomcat-#{node['tomcat8']['tomcat_version']}.tar.gz" do
  action :delete
  only_if { File.exist? "#{node['tomcat8']['tmp_path']}/apache-tomcat-#{node['tomcat8']['tomcat_version']}.tar.gz" }
end

# chown tomcat group to tomcat base folder
execute "set #{node['tomcat8']['tomcat_base']} permissions" do
  command "chgrp -R tomcat #{node['tomcat8']['tomcat_base']}"
 cwd node['tomcat8']['tomcat_base']
  action :run
end     

# assign read permissiosn to tomcat_base/conf folder
execute "set #{node['tomcat8']['tomcat_base']}/conf permissions" do
  command "chmod -R g+r conf"
  cwd node['tomcat8']['tomcat_base']
  action :run
end

# assign execute permissions to tomcat_base/conf fodler 
execute "set #{node['tomcat8']['tomcat_base']}/conf execute permissions" do
  command "chmod -R g+x conf"
  cwd node['tomcat8']['tomcat_base']
  action :run
end

# assign tomcat user ownership to tomcat_base/webapps, logs and temp folders
execute "set #{node['tomcat8']['tomcat_base']}/conf execute permissions" do
  command "chown -R tomcat webapps/ work/ temp/ logs/"
  cwd node['tomcat8']['tomcat_base']
  action :run
end

# install tomcat8 systemd unit file
cookbook_file "#{node['tomcat8']['tomcat_systemd_unit_path']}" do
  source 'systemd-unit-tomcat8'
  owner  node['tomcat8']['user']
  group  node['tomcat8']['group']
  mode '0755'
  action :create
end

# reload systemd service 
execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

# start tomcat8 service
service node['tomcat8']['tomcat_service_name'] do
  action [:enable, :start]
end
