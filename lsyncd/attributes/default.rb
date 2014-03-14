# settings
default["lsyncd"]["conf"] = "/etc/lsyncd.lua"
default["lsyncd"]["logfile"] = "/var/log/lsyncd.log"
default["lsyncd"]["statusfile"] = "/var/log/lsyncd/lsyncd-status"
default["lsyncd"]["statusinterval"] = 5
# sync
default["lsyncd"]["source1"] = "/var/tmp/source"
default["lsyncd"]["targethost1"] = "127.0.0.1"
default["lsyncd"]["targetdir1"] = "/var/tmp/dest"
# rsync

default["lsyncd"]["compress1"] = "true"
default["lsyncd"]["archive1"] = "true"
default["lsyncd"]["verbose1"] = "true"
default["lsyncd"]["rsh1"] = "/usr/bin/ssh -p 22 -o StrictHostKeyChecking=no"
