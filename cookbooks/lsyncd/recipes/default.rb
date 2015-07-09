#
# Cookbook Name:: lsyncd
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

case
node["platform_family"]
when "rhel"
  # install lsync
  package "lsyncd"
  # standardize lsync location, allowing it to start without init modification 
  template "/etc/init.d/lsyncd" do
  source "rhel/lsyncd_init.erb"
  variables({
	:conf => node["lsyncd"]["conf"] 
  })
  mode "0755"
  end

  # create logging dir for lsyncd
  directory "/var/log/lsyncd" do
    owner "root"
    group "root"
    action :create
    end
  
  # create logrotate file
  template "/etc/logrotate.d/lsyncd" do
    source "lsyncd_log.erb"
    action :create
  end

  # create dirs for testing lsyncd
  directory "/var/tmp/source" do
    owner "root"
    group "root"
    action :create
  end

  directory "/var/tmp/dest" do
    owner "root"
    group "root"
    action :create
  end

when "debian" 
   ## lsyncd package is broken in Ubuntu so we compile from source
   # update repos to fix missing mirror issue.
   execute "apt-get update" do
   command "apt-get update"
   end
   # install packages required for compiling
   
   packages = ['lua5.1', 'liblua5.1-0', 'liblua5.1-dev', 'pkg-config', 'rsync', 'asciidoc', 'make']
   packages.each do |packageList|
   apt_package "#{packageList}" do
     action :install
   end
   end
   
   
   # Grab tar and extract
   remote_file "#{Chef::Config[:file_cache_path]}/lsyncd-2.1.4.tar.gz" do
     source "http://lsyncd.googlecode.com/files/lsyncd-2.1.4.tar.gz" 
   end
   
   execute  "tar -xvf #{Chef::Config[:file_cache_path]}/lsyncd-2.1.4.tar.gz -C #{Chef::Config[:file_cache_path]}" do
     command  "tar -xvf #{Chef::Config[:file_cache_path]}/lsyncd-2.1.4.tar.gz -C #{Chef::Config[:file_cache_path]}"
   end 


   # start compiling lsyncd
   execute "install lsyncd" do
   cwd  "#{Chef::Config[:file_cache_path]}/lsyncd-2.1.4"
   command "./configure && make && make install"
   end

   # Create /etc/init/lsyncd.conf template
   template "/etc/init/lsyncd.conf" do
      source "lsyncd_conf.erb"
      action :create
   end

   # Create upstart job
   link "/lib/init/upstart-job" do 
     to "/etc/init.d/lsyncd"
     link_type :symbolic
   end
      
   # create dir for logroate
   directory "/var/log/lsyncd" do
     owner "root"
     group "root"
     action :create
   end 
       
   # logrotate
    template "/etc/logrotate.d/lsyncd" do
       source "lsyncd_log.erb"
       action :create
   end
    
   # create dirs for testing lsyncd
   directory "/var/tmp/source" do
      owner "root"
      group "root"
      action :create
   end 

   directory "/var/tmp/dest" do
      owner "root"
      group "root"
      action :create
   end
     
end

# lsyncd.lua script

template "/etc/lsyncd.lua" do 
   source "lsyncd_lua.erb"
   variables({
	# setings
	:logfile => node["lsyncd"]["logfile"],
	:statusfile => node["lsyncd"]["statusfile"],
	:statusinterval => node["lsyncd"]["statusinterval"],
	# sync 
	:source1 => node["lsyncd"]["source1"],
        :targethost1 => node["lsyncd"]["targethost1"],
	:targetdir1 => node["lsyncd"]["targetdir1"],
	# rsync 
	:compress1 => node["lsyncd"]["compress1"],
	:archive1  => node["lsyncd"]["archive1"],
	:verbose1  => node["lsyncd"]["verbose1"],
	:rsh1	   => node["lsyncd"]["rsh1"],
   })
end

# start it up 
case
node["platform_family"]
when "rhel"
  service "lsyncd" do
    action [ :enable, :start]
  end


when "debian"
   service "lsyncd" do
        provider Chef::Provider::Service::Upstart
        action [ :enable, :start]
   end
end

