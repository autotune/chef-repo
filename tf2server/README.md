TF2 Server Cookbook
============
Installs Team Fortress 2 Dedicated Server.    

CentOS WARNING: In order to simplify things, this will back up and replace your current iptables rules at /etc/sysconfig/iptables-tf2.bac rather than add to them. It is recommended you install this as part of a fresh installation on a server in your own LAN or at a VPS/Cloud provider. In Ubuntu, this recipe uses UFW to dynamically add to the rules. 

Requirements
------------
#### packages
Requires firewall cookbook.

Attributes
----------
### server.cfg
default["tf2server"]["hostname"] = "Your_Servers_Name"

default["tf2server"]["password"] = "Your_Rcon_Password"

default["tf2server"]["sv_contact"] = "admin@yourdomain.com"

default["tf2server"]["mp_timelimit"] = "30"

Usage
-----
#### tf2server::default

Contributing
------------

License and Authors
-------------------
Authors: Brian Adams

License: GPLV3 (http://choosealicense.com/licenses/gpl-v3) 
