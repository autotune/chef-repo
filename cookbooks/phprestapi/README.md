PHP-SAMPLE-API Cookbook
=======================

URL
--

https://github.com/paypal/rest­api­sample­app­php/

Requirements
------------
Distro: CentOS 6.5 (should work across CentOS 6.x)

    sudo -s
    curl -L https://www.opscode.com/chef/install.sh | bash
    alias chefrun='chef-solo -c /root/chef-repo/solo.rb -j /root/chef-repo/web.json'
    chefrun
    exit

Attributes
----------
default['phpsampleapi']['mysql']['db'] = "phpsampleapi"

default['phpsampleapi']['mysql']['user'] = "apidbdev"


Usage
-----

This recipe has been tested through chef-solo and snapshot creation/regression through VirtualBox. 

Nothing more needs to be done other than specifying which attributes are preferred and running recipe. 

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
