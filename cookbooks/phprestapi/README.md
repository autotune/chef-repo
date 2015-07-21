New Relic Cookbook
=================


Requirements
------------

Attributes
----------
default['phpsampleapi']['mysql']['db'] = "phpsampleapi"

default['phpsampleapi']['mysql']['user'] = "apidbdev"


Usage
-----

This recipe has been tested through chef-solo and snapshot creation/regression through VirtualBox. 

ToDo
---

Dependency Management => Berkshelf 

Cookbook Cleanup => implement database cookbook and replace one-liners

Testing => Implement unit testing with ChefSpec and state testing with Serverspec 
 

#### phpsampleapi::default

License and Authors
-------------------

Authors: Brian Adams 

License: MIT 
