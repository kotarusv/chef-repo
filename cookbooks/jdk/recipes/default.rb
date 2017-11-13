#
# Cookbook:: jdk
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


apt_update 'update'

execute 'remove default open jdk versions' do
  command "apt-get purge openjdk-*"
end 

cookbook_file "#{node['jdk']['tmp_path']}/#{node['jdk']['version']}-linux-x64.tar.gz"  do
  source 'jdk-8u151-linux-x64.tar.gz'
  mode '0755'
  action :create
end

directory "#{node['jdk']['jdk_install_path']}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'extract oracle jdk  tar.gz filer' do
  command "tar xzvf jdk-8u151-linux-x64.tar.gz -C #{node['jdk']['jdk_install_path']} --strip-components=1"
  cwd node['jdk']['tmp_path']
end

execute "set right permissions on #{node['jdk']['jdk_install_path']}" do
 command "chown -R root:root #{node['jdk']['jdk_install_path']}"
 action :run
end

execute "set right permissions on #{node['jdk']['jdk_install_path']}" do
 command "chmod -R 755 #{node['jdk']['jdk_install_path']}"
 action :run
end
 

file "#{node['jdk']['tmp_path']}/#{node['jdk']['version']}-linux-x64.tar.gz" do
  action :delete
  only_if { File.exist? "#{node['jdk']['tmp_path']}/#{node['jdk']['version']}-linux-x64.tar.gz" }
end


execute 'set oracle jdk-java as default' do
  command "update-alternatives --install /usr/bin/java java #{node['jdk']['jdk_install_path']}/bin/java 100"
  action :run
end


execute 'set oracle jdk-javac as default' do
  command "update-alternatives --install /usr/bin/javac javac #{node['jdk']['jdk_install_path']}/bin/javac 100"
  action :run
end
