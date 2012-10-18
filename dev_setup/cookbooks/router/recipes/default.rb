#
# Cookbook Name:: router
# Recipe:: default
#
# Copyright 2011, VMware
#


bash "git clone router" do
  code <<-EOH
    if [ ! -e #{node[:cloudfoundry][:home]}/router ]
    then
      cd #{node[:cloudfoundry][:home]}
      git clone https://github.com/cloudfoundry/router.git
    fi
  EOH
end

cf_bundle_install(File.expand_path("router", node[:cloudfoundry][:home]))

service "router" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
      
template node[:router][:config_file] do
   path File.join(node[:deployment][:config_path], node[:router][:config_file])
   source "router.yml.erb"
   owner node[:deployment][:user]
   mode 0644
  notifies :restart, "service[router]"
end

