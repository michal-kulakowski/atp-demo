#!/bin/bash

psql -U phoenix phoenixdb -c "UPDATE ph_sys_conf SET value='mail.mailinator.com' WHERE property='Mail_Server';"