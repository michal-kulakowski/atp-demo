#!/bin/bash

cp -r config/discoverFile /opt/phoenix/config
chown -R admin:admin /opt/phoenix/config/discoverFile
sed -i.orig 's/^output_cmdbupdate_to_file.*/output_cmdbupdate_to_file=1 #0: no 1: yes/' /opt/phoenix/config/phoenix_config.txt
sed -i 's/^discover_from_file.*/discover_from_file=1 #0:from network; 1:from file/' /opt/phoenix/config/phoenix_config.txt