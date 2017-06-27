/root/demo/2017/restart_perf_replay.sh

/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/9_vuln_scan -l 1
sleep 20
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/1_scan_deny/ -l 1
sleep 20
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/2_scan_permit/ -l 1
sleep 60
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/3_vpn_auth_fail/ -l 1
sleep 61
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/4_vpn_auth_fail/ -l 1
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/5_vpn_auth_success/ -l 1
sleep 21
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/11_windows_exploit/ -l 1
sleep 5
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/6_windows_compromise/6.1_pth/ -l 1
sleep 5
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/6_windows_compromise/6.1.1_auth_suc -l 1
sleep 1
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/6_windows_compromise/6.1.2._rdp_traf/ -l 100 &
sleep 21
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/6_windows_compromise/6.2_bro/ -l 1
sleep 21
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/6_windows_compromise/6.3_reg_changes/ -l 1
sleep 21
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/6_windows_compromise/6.4_fim/ -l 1
sleep 21
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/6_windows_compromise/6.5_new_proc/ -l 1
sleep 60
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/7_sql_query/ -l 1
/root/baseline-data/high_sql_cpu.sh &
sleep 60
/root/demo/2017/bin/sendEvents -r 1 -d 127.0.0.1 -m /root/demo/2017/scenario1/events/8_data_exfil/ -l 1
