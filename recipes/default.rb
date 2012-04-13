# 
# Cookbook Name:: VRTSralus
# Recipe:: default
#
# Copyright 2011, Bryan W. Berry
#
# Apache 2.0

include_recipe "yumrepo::corporate"

# load passwd for bexec user from encrypted databags
# http://www.opscode.com/blog/2011/04/29/chef-0-10-preview-encrypted-data-bags
bexec_passwd = Chef::EncryptedDataBagItem.load("stash", "stuff")['bexec_passwd']

# load media servers from data bag
media_servers = node['bex_media_servers']

package "compat-libstdc++-33" do
	:install
end

package "VRTSralus" do
	:install
end

cookbook_file "/etc/init.d/VRTSralus.init" do
	source "VRTSralus.init"
	mode "0750"
	notifies :restart, "service[VRTSralus.init]"
end

service "VRTSralus.init" do
	action [:enable, :start]
end

template "/etc/VRTSralus/ralus.cfg" do
	source "ralus.cfg.erb"
	variables( :media_servers => media_servers )
end

user "bexec" do
	home	"/home/bexec"
	shell	"/bin/bash"
	password	bexec_passwd 
	supports({ :manage_home => true })
end

group "beoper" do
	members [ "bexec" ]
end

