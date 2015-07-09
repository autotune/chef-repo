#
# Cookbook Name:: tf2
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Requirements.
include_recipe "tf2server::firewall"

case
node["platform_family"]
 
when "rhel"
# replace iptables rules
  execute "backup-iptables" do
    command "mv /etc/sysconfig/iptables /etc/sysconfig/iptables-tf2.bac"
  end

  template "/etc/sysconfig/iptables" do
     source "iptables.erb"
     owner "root"
     group "root"
     mode 00775
   end

  service "iptables" do
    action :restart
  end

# libgcc.i686 breaks without upgrade
  yum_package "libgcc.x86_64" do
     action :upgrade
  end

  packages = ['glibc.i686', 'libgcc.i686', 'screen', 'ncompress']
     packages.each do |packageList|
       yum_package "#{packageList}" do
         action :install
  end
end

when "debian"
  # update packages   
  execute "update-repos" do
    command "apt-get update"
  end

  # install libs  
  packages = ['lib32gcc1', 'ia32-libs']
    packages.each do |packageList|
      apt_package "#{packageList}" do
        action :install
   end
end
end

# create system user dir

directory "/home/tf2server" do
  owner "root"
  group "root"
  mode 00775
  action :create
end

# create system user
user "tf2server" do
   comment "tf2server"
   system true
   action :create
end

# create scripts directory

directory "/home/tf2server/hlserver" do
   owner "root"
   group "root"
   mode 00775
   action :create
end

directory "/home/tf2server/hlserver/tf2/" do
  owner "root"
  group "root"
  mode 00775
  action :create
end

directory "/home/tf2server/hlserver/tf2/tf/" do
  owner "root"
  group "root"
  mode 00775
  action :create
end

directory "/home/tf2server/hlserver/tf2/tf/cfg" do
  owner "root"
  group "root"
  mode 00775
  action :create
end
 
# add steamcmd script
template "/home/tf2server/hlserver/tf2_ds.txt" do
  source "tf2_ds.erb"
  owner "root"
  group "root"
  mode 00775
end 

# updating batch file
template "/home/tf2server/hlserver/update.sh" do
   source "update.erb"
   owner "root"
   group "root"
   mode 00775
end

# update server files
template "/home/tf2server/hlserver/tf2/tf/cfg/server.cfg" do
   source "server.erb"
   owner "root"
   group "root"
   mode 00775
   variables({
     :hostname => node["tf2server"]["hostname"],
     :password => node["tf2server"]["password"],
     :sv_contact => node["tf2server"]["sv_contact"],
     :mp_timelimit => node["tf2server"]["mp_timelimit"]
   })
end

# create shell script
template "/home/tf2server/hlserver/tf.sh" do
  source "tf.erb"
  owner "root"
  group "root"
  mode 00775
end

# create conf file
template "/etc/init/tf2-server.conf" do
   source "tf2_init.erb"
   owner "root"
   group "root"
   mode 00775
end

# grab tar and extract
remote_file "#{Chef::Config[:file_cache_path]}/steamcmd_linux.tar.gz" do
  source "http://media.steampowered.com/client/steamcmd_linux.tar.gz"
end

execute "extract-steamcmd-tool" do
   command "tar -xvf #{Chef::Config[:file_cache_path]}/steamcmd_linux.tar.gz -C /home/tf2server/hlserver"
end

# start update
execute "run-steamcmd-update" do
   command "/home/tf2server/hlserver/update.sh"
end

# run server
service "tf2-server" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true
  action [ :enable, :start]
end

