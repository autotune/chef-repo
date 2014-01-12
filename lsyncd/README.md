lsyncd Cookbook
===============
This is a cookbook for lsyncd which makes the installation and setup for one remote server by default a snap on both Ubuntu and CentOS. When done, Lsync will be up and running with test directories in /var/tmp/source and /var/tmp/dest for testing purposes. Make sure you configure the localhost just like you would a remote server, adding a private RSA key and then 127.0.0.1 to the authorized_keys2 file if you want to test locally first as lsyncd will not start unless a server has been succesfully added.  


Requirements
------------
Tested as working on Ubuntu 10.04 and 13.10 and up and Centos 6.4. CentOS is more stable for this as it installs from repos rather than compiling from source for a working version.

Attributes
----------
SEE: Default attributes file. 

Usage
-----

Contributing
------------

License and Authors
-------------------
Authors: Brian Adams
License: MIT License
