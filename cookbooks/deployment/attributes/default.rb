node.default['deployment']['cookbook_path'] = "/opt/chef-repo/cookbooks/deployment"
node.default['deployment']['artifact_url'] = "https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample"
node.default['deployment']['filename'] = "sample.war"
node.default['deployment']['port'] = "9000"
node.default['deployment']['tomcat_base'] = "/opt/tomcat"