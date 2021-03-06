#
# Cookbook Name:: nats
# Recipe:: default
#
# Copyright 2011, VMware
#

include_recipe "nats_server::cloud"

gem_package "nats" do
  gem_binary File.join(node[:ruby][:path], "bin", "gem")
  version "0.4.26"
end

nats_config_dir = File.join(node[:deployment][:config_path], "nats_server")
node.set[:nats_server][:config] = File.join(nats_config_dir, "nats_server.yml")

directory nats_config_dir do
  owner node[:deployment][:user]
  mode "0755"
  recursive true
  action :create
end

template "nats_server.yml" do
  path node[:nats_server][:config]
  source "nats_server.yml.erb"
  owner node[:deployment][:user]
  mode 0644
end



case node['platform']
when "ubuntu"
  template "nats_server" do
    path File.join("", "etc", "init.d", "nats_server")
    source "nats_server.erb"
    owner node[:deployment][:user]
    mode 0755
  end

  service "nats_server" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end
else
  Chef::Log.error("Installation of nats_server not supported on this platform.")
end

