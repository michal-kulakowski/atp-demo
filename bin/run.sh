#!/bin/bash

bin/sendEvents -r 1 -d 127.0.0.1 -m config/events/1_malware_downloaded -l 1
sleep 20
bin/sendEvents -r 1 -d 127.0.0.1 -m config/events/2_smb_outbreak -l 1

