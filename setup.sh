#!/bin/bash

echo -n "Installing Discovery Data: "
bin/install_discovery_data.sh
echo "DONE"
echo -n "Configuring mail Server: "
bin/install_mail_server.sh
echo "DONE"
echo -n "Restarting Services: "
phtools --stop ALL && phtools --stop phMonitor > /dev/null 2>&1 &
while [ `/opt/phoenix/bin/phstatus.py | grep DOWN | wc | awk '{print $1}'` != "0" ]; do
	echo -n ".";
	sleep 1;
done
echo "DONE"
