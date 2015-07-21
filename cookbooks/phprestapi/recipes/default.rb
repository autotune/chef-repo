# Cookbook Name: New Relic 
# Recipe:: default


case node["platform_family"]
when "rhel"

# install epel repo
  rpm_package "epel-release-6-8.noarch.rpm" do
    source "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm"
    action :install
  end

# install IUS repo
  rpm_package "ius-release-1.0-14.ius.centos6.noarch.rpm" do
    source "#{Chef::Config[:file_cache_path]}/ius-release-1.0-14.ius.centos6.noarch.rpm"
    action :install
  end

# install required packages 
# exact versions in /var/log/yum.log
  yum_package 'system_packages' do
    package_name ['wget', 'git', 'yum-plugin-replace']
    version ['1.12-5.el6_6.1', '1.7.1-3.el6_4.1', '0.2.7-1.ius.centos6']
    flush_cache[ :before ]
    action :install
end

  # replace mysql-libs with mysql55-libs
  execute "remove mysql-libs without removing deps" do
  command "rpm -e mysql-libs --nodeps"
  action :run
  end 

  yum_package 'database_packages' do
  package_name ['mysql55-server' ]
    version ['5.5.44-2.ius.centos6']
    flush_cache[ :before ]
    action :install
  end

  yum_package 'web_packages' do
  package_name ['php' ] 
    version ['5.3.3-46.el6_6']
    flush_cache[ :before ] 
    action :install
end
 
  # execute "echo" do
  # command "echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list"
  # creates "/home/rack/chef.txt"
  # action :run
  # end
end
