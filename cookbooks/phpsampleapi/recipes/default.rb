# Cookbook Name: phpsampleapi 
# Recipe:: default


case node["platform_family"]
when "rhel"

######################
# ADD DEDICATED USER #
######################

user "#{node[:phpsampleapi][:apache][:user]}" do
  supports :manage_home => true
  comment 'API User'
  home "/home/#{node[:phpsampleapi][:apache][:user]}"
  shell '/bin/bash'
end

#############################
# INSTALL REQUERED PACKAGES #
############################# 

  # flush the cache
  execute "flush-yum-cache" do
  command "yum clean all"
  end

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
# if wanted to reuse we could create seperate recipes and add as roles
  yum_package 'system_packages' do
    package_name ['wget', 'git', 'yum-plugin-replace', 'expect', 'gcc']
    version ['1.12-5.el6_6.1', '1.7.1-3.el6_4.1', '0.2.7-1.ius.centos6', '5.44.1.15-5.el6_4', '4.4.7-11.el6']
    flush_cache[ :before ]
    action :install
end

  # flush the cache
  execute "flush-yum-cache" do
  command "yum clean all"
  end

  # replace mysql-libs with mysql55-libs
  execute "remove-mysql-libs-nodeps" do
  command "rpm -e mysql-libs --nodeps"
  # only if mysql-libs is installed 
  only_if "rpm -qa|grep mysql-libs" 
  action :run
  end 

  yum_package 'database_packages' do
  package_name ['mysql55-server' ]
    version ['5.5.44-2.ius.centos6']
    flush_cache[ :before ]
    action :install
  end

  yum_package 'web_packages' do
  package_name ['php','php-mysql' ] 
    version ['5.3.3-46.el6_6', '5.3.3-46.el6_6']
    flush_cache[ :before ] 
    action :install
end

  service 'mysqld' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

  service 'httpd' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# this assumes a fresh install 
# this also assumes reject by default 
  execute 'backup-iptables' do
    command 'cp /etc/sysconfig/iptables /etc/sysconfig/iptables.bac'
  end

  execute 'find-reject-rule' do
    command 'echo "$(iptables -L INPUT --line-numbers | grep \'REJECT\' | awk \'{print $1}\')" > /tmp/iprule.txt'
  end
   # some images have weird options for rules so should be 
   # as generic as possible. e.g. Rackspace CentOD 6 vs 
   # standard CentOS 6 minimal ISO have diff ssh rules. 
   execute "drop-port-ssh" do
   command "sed '/--dport 22 -j ACCEPT'/d -i /etc/sysconfig/iptables"
   end

  execute 'allow-all-80' do
    # http://unix.stackexchange.com/questions/121161/how-to-insert-text-after-a-certain-string-in-a-file => solution for before match located here as well. 
    command 'sed \'/INPUT \-j REJECT/i -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT -m comment --comment \"ALL from 80"\' -i /etc/sysconfig/iptables'
  end

  execute 'allow-all-443' do
    command 'sed \'/INPUT \-j REJECT/i -A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT -m comment --comment \"ALL from 443"\' -i /etc/sysconfig/iptables'
  end

  execute 'allow-10.0.0.0-ssh' do
    command 'sed \'/INPUT \-j REJECT/i -A INPUT -s 10.0.0.0/8 -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT -m comment --comment \"SSH from 10.0.0.0/8"\' -i /etc/sysconfig/iptables'
  end

  execute 'allow-192.168.0.0-ssh' do
    command 'sed \'/INPUT \-j REJECT/i -A INPUT -s 192.168.0.0/16 -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT -m comment --comment \"SSH from 192.168.0.0/16"\' -i /etc/sysconfig/iptables'
  end

  execute 'allow-172.0.0.0-ssh' do
    command 'sed \'/INPUT \-j REJECT/i -A INPUT -s 172.0.0.0/8 -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT -m comment --comment \"SSH from 172.0.0.0/8"\' -i /etc/sysconfig/iptables'
  end

  service 'iptables' do
  supports :restart => true, :reload => true
  action [ :restart ]
end

#############################
# COPY REQUIRED CONFIG FILES#
#############################
   
  # extract files directly to /var/www/html   
  execute "extract-phprestapi" do
  command "tar xvf #{Chef::Config[:file_cache_path] + '/rest-api-sample-app-php.tar.gz' + " -C /var/www/html --strip-components 1"}"
  action :run
  end 

  # extract change user permissions for /var/www/html   
  execute "change-ownership-permissions" do
  command "chown -R #{node[:phpsampleapi][:apache][:user]}:#{node[:phpsampleapi][:apache][:user]} /var/www/html"
  action :run
  end 
  
  # make user default group   
  execute "change-group-sticky" do
  command "chmod -R g+s /var/www/html"
  action :run
  end 

  # install composer
  execute "install-composer" do
  command "curl -sS https://getcomposer.org/installer | php -- --install-dir=/var/www/html"
  end

  execute "update-composer" do 
  cwd "/var/www/html" 
  command "php composer.phar update"
  end 
  
  execute "change-group-permissions" do
  command "chmod -R 775 /var/www/html"
  end

#####################
# CONFIGURE DATABASE#
#####################

  # generate secure pass
  execute "mysql-secure-pass" do
  command "echo -e \"[client]\nuser=root\npassword=$(date +%s | sha256sum | base64 | head -c 14 ; echo)\" > /root/.my.cnf"
  end 

  # back up secure_installation.expect 
  execute "secure_installation_backup" do
  command "cp #{Chef::Config[:file_cache_path] + '/secure_installation.expect'} #{Chef::Config[:file_cache_path] + '/secure_installation.expect.bac'}"
  action :run 
  end

  # replace CHANGE_ME with secure password
  execute "mysql-user-pass" do
  command "sed \"s/\"CHANGE_ME\"/$(grep password /root/.my.cnf|tr '=' ' '|awk '{print $2}')/\" /root/chef-repo/file_cache/secure_installation.expect -i #{Chef::Config[:file_cache_path] + '/secure_installation.expect'}"
  action :run
  end

  # expect an auto install 
  execute "mysql-secure-installation" do
  command "expect #{Chef::Config[:file_cache_path] + '/secure_installation.expect'}"
  action :run 
  end

  # clean up secure_installation  
  execute "secure_installation_cleanup" do
  command "cp #{Chef::Config[:file_cache_path] + '/secure_installation.expect.bac'} #{Chef::Config[:file_cache_path] + '/secure_installation.expect'}"
  action :run 
  end

  # add bootstrap database
  execute "add-phprestapi-db" do
  command "mysql -e 'CREATE DATABASE #{ node[:phpsampleapi][:mysql][:db]}'"
  not_if "mysql -e 'show databases'|grep #{ node[:phpsampleapi][:mysql][:db]}"
  end

  # add bootstrap user password
  execute "add-phprestapi-db-user-pw" do
  command "echo -e \"$(date +%s | sha256sum | base64 | head -c 14 ; echo)\" > /tmp/dbuserpw.txt"
  end

  # add bootstrap user grant
  execute "add-phprestapi-db-user-grants" do
  command "mysql -e \"use phpsampleapi; GRANT ALL ON #{ node[:phpsampleapi][:mysql][:db]}.* TO #{ node[:phpsampleapi][:mysql][:user]}@localhost IDENTIFIED BY \\\"$(cat /tmp/dbuserpw.txt)\\\"\""
  end

  execute "replace-boostrap-user" do
  command "sed 's/'MYSQL_USERNAME\\'\\,\\ \\'root'/\\'MYSQL_USERNAME\\',\\ \\'#{ node[:phpsampleapi][:mysql][:user]}'/' -i /var/www/html/app/bootstrap.php"
  end

  # replace bootstrap user pass
  execute "replace-boostrap-user-pw" do
  command "sed 's/'MYSQL_PASSWORD\\'\\,\\ \\'root'/\\'MYSQL_PASSWORD\\',\\ \\'$(cat /tmp/dbuserpw.txt)'/' -i /var/www/html/app/bootstrap.php"
  end

  # replace bootstrap db name
  execute "replace-boostrap-db-name" do
  command "sed 's/'MYSQL_DB\\'\\,\\ \\'paypal_pizza_app'/\\'MYSQL_DB\\',\\ \\'#{ node[:phpsampleapi][:mysql][:db]}'/' -i /var/www/html/app/bootstrap.php"
  end

  # cleanup tmp password
  execute "delete-tmp-passwd" do
  command "rm -f /tmp/dbuserpw.txt"
  end


# final end
end
