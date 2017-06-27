killall -9 sendPerfEvents &>/dev/null
/root/demo/2017/bin/sendPerfEvents -d 127.0.0.1 -m /root/demo/2017/perf -c /root/demo/2017/ctrl &>/root/demo/2017/logs/perf.log &
