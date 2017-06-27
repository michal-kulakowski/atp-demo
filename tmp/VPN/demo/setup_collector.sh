#!/bin/bash
#dhanman@fortinet.com - modified for CSE labs

myIP=`ifconfig eth0 | grep "inet addr:" | awk -F ':' '{ print $2 }' | awk '{ print $1 }'`
hostname=$(hostname -s)

RED='\033[31m'
BLUE='\033[34m'
NC='\033[0m'

echo ""
echo "(c) 2017 Fortinet CSE ----- FortiSIEM VPN Demo - Collector Setup -----"
echo ""
echo "#######################################################################################################################"
echo ""
echo "          _______  _          ______   _______  _______  _______ "
echo "|\     /|(  ____ )( (    /|  (  __  \ (  ____ \(       )(  ___  )"
echo "| )   ( || (    )||  \  ( |  | (  \  )| (    \/| () () || (   ) |"
echo "| |   | || (____)||   \ | |  | |   ) || (__    | || || || |   | |"
echo "( (   ) )|  _____)| (\ \) |  | |   | ||  __)   | |(_)| || |   | |"
echo " \ \_/ / | (      | | \   |  | |   ) || (      | |   | || |   | |"
echo "  \   /  | )      | )  \  |  | (__/  )| (____/\| )   ( || (___) |"
echo "   \_/   |/       |/    )_)  (______/ (_______/|/     \|(_______)"
echo "#######################################################################################################################"
echo ""
                                                      

echo -e "What is the Supervisor IP Address?"
read superip
echo $superip > /root/scripts/superIP.conf
echo ""
echo "The Supervisor IP has been set as: $superip"
echo ""



echo "Setting Script Permissions"
chmod u+x  /root/demo/2017/1_scenario_replay.sh
chmod u+x  /root/demo/2017/restart_perf_replay.sh
chown -R admin.admin /opt/phoenix/config/discoverFile/

echo "Setting Up Hosts File....."
echo "10.10.100.27 ORDERS-ERP" >> /etc/hosts
echo "Hosts Done"
echo ""

echo "Setting Binary Permissions"
chmod u+x /root/demo/2017/bin/*

echo "Setting cron up"

crontab -l > /root/defaultCron.txt
cat /root/demo/2017/scenario1/cron.out >>  /root/defaultCron.txt
crontab /root/scripts/crontest.out
cat /root/scripts/crontest.out >> /opt/phoenix/config/sys/var/spool/cron/root


echo "Setting File Based Discovery"
cd /opt/phoenix/config/		   
cp phoenix_config.txt phoenix_config.bak
sed -i 's/discover_from_file=0/discover_from_file=1/g' phoenix_config.txt
echo "$(date) - Set to Local File Discovery" >> /root/scripts/current_discov_status.log
killall -9 phDiscover

echo "Waiting 45 seconds for Discovery Process to Restart"
sleep 45
if ps -aef | grep [p]hDiscover
then 
   echo "Discovery Process Restarted OK";
else
   echo "Check phDisocver Process via phstatus, process not restarted";
fi

echo ""
echo "Next steps:"
echo "1) You need to discover the devices 10.10.100.27, 192.168.3.1. Do this by creating an SNMP \
credential, associate that credential to the IP addresses the create a discovery. When creating \
the Discovery profile make sure that you set \"Do not ping before discovery\" and \"Name Resolution\"\
set to \"SNMP/WMI first\""
echo ""
echo "If you have a problem, please report on the Fuse FortiSIEM forum."


echo "Setup Complete!"


