#!/bin/bash

echo -n "Installing discovery data: "
bin/install_discovery_data.sh > ./setup.log 2>&1
echo "DONE"
echo -n "Configuring mail server: "
bin/install_mail_server.sh > ./setup.log 2>&1
echo "DONE"
echo -n "Restarting Services: ."
phtools --stop ALL > ./setup.log 2>&1
phtools --stop phMonitor > ./setup.log 2>&1
while [ `/opt/phoenix/bin/phstatus.py | grep DOWN | wc | awk '{print $1}'` != "0" ]; do
	echo -n ".";
	sleep 1;
done
echo "DONE"
