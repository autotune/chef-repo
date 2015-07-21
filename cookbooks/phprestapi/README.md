PHP-SAMPLE-API Cookbook
=======================

URL
--

https://github.com/paypal/rest­api­sample­app­php/

Requirements
------------

Attributes
----------
default['phpsampleapi']['mysql']['db'] = "phpsampleapi"

default['phpsampleapi']['mysql']['user'] = "apidbdev"


Usage
-----

This recipe has been tested through chef-solo and snapshot creation/regression through VirtualBox. 

    sudo -s
    curl -L https://www.opscode.com/chef/install.sh | bash
    alias chefrun='chef-solo -c /root/chef-repo/solo.rb -j /root/chef-repo/web.json'
    chefrun
    exit

ToDo
----

Dependency Management => Berkshelf 

Cookbook Cleanup => implement database cookbook and replace one-liners

Testing => Implement unit testing with ChefSpec and state testing with Serverspec 
 

Additional Notes
----------------

This cookbook creates a dedicated user under MySQL and runs apache under standard apache user. 
Sudoer is required to install mysql and httpd packages. 

#### phprestapi::default

License and Authors
-------------------

Authors: Brian Adams 

License: MIT 
