#!/usr/bin/env bash

mkdir -p /etc/swanagent

CFGGEN_PARAMS=" \
    -d \
    -y /etc/sonic/constants.yml \
"
sonic-cfggen $CFGGEN_PARAMS

mkdir -p /var/sonic
echo "# Config files managed by sonic-config-engine" > /var/sonic/config_status

rm -f /var/run/rsyslogd.pid

supervisorctl start rsyslogd
supervisorctl start swsscommongrpcserver
supervisorctl start swanagent

