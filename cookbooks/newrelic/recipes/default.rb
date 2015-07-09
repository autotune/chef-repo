# Cookbook Name: New Relic 
# Recipe:: default


case node["platform_family"]
when "rhel"
   # fetch the New Relic repo
    remote_file "#{Chef::Config[:file_cache_path]}/newrelic-repo-5-3.noarch.rpm" do
    source 'https://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm'
end

  rpm_package "newrelic-repo-5-3.noarch.rpm" do
    source "#{Chef::Config[:file_cache_path]}/newrelic-repo-5-3.noarch.rpm"
    action :install
  end
  # install New Relic
  package 'newrelic-sysmond'
 
when "debian"
  # add the New Relic source
  execute "echo" do
  command "echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list"
  creates "/home/rack/chef.txt"
  action :run
  end
  # trust the New Relic GPG key
  execute "wget" do
  command "wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -"
  action :run
 end
  # update aptitude
  execute "apt-get update" do
  command "apt-get update"
  action :run
 end
  # install the package
  apt_package "newrelic-sysmond" do
  action :install
 end

# template and license number
template "/etc/newrelic/nrsysmond.cfg" do
  source "nrsysmond.cfg.erb"
  variables({
	:license => node['newrelic']['license']
  })
  action :create
end

# restart
service "newrelic-sysmond" do
  supports :restart => true
  action [ :enable, :start]
end

end
