case node["platform_family"]
when "rhel"
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

  # replace bootstrap user 
  execute "replace-boostrap-user" do
  command "sed 's/'MYSQL_USERNAME\\'\\,\\ \\'root'/\\'MYSQL_USERNAME,\\ \\'#{ node[:phpsampleapi][:mysql][:user]}'/' -i /var/www/html/app/bootstrap.php"
  end

  # replace bootstrap user pass 
  execute "replace-boostrap-user-pw" do
  command "sed 's/'MYSQL_PASSWORD\\'\\,\\ \\'root'/\\'MYSQL_PASSWORD,\\ \\'$(cat /tmp/dbuserpw.txt)'/' -i /var/www/html/app/bootstrap.php"
  end

  # replace bootstrap db name 
  execute "replace-boostrap-db-name" do
  command "sed 's/'MYSQL_DB\\'\\,\\ \\'paypal_pizza_app'/\\'MYSQL_DB,\\ \\'#{ node[:phpsampleapi][:mysql][:db]}'/' -i /var/www/html/app/bootstrap.php"
  end

# final end
end
