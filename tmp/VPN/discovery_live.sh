cd /opt/phoenix/config/		   
cp phoenix_config.txt phoenix_config.bak
sed -i 's/discover_from_file=1/discover_from_file=0/g' phoenix_config.txt
echo "$(date) - Set to Live Device Discovery" >> /root/scripts/current_discov_status.log
killall -9 phDiscover

echo "Waiting 45 seconds for Discovery Process to Restart"
sleep 45
if ps -aef | grep [p]hDiscover
then 
   echo "Discovery Process Restarted OK";
else
   echo "Check phDisocver Process via phstatus, process not restarted";
fi
