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
      git clone #{node[:cloudfoundry][:git_url]}/router.git
    fi
  EOH
end

template "router" do
  path File.join("", "etc", "init.d", "router")
  source "router.erb"
  owner node[:deployment][:user]
  mode 0755
end

template "logrotate" do
  path File.join("", "etc", "logrotate.d", "router")
  source "logrotate.erb"
  owner node[:deployment][:user]
  mode 0755
end
      
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

cf_bundle_install(File.expand_path("router", node[:cloudfoundry][:path]))
