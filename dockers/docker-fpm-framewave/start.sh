#!/usr/bin/env bash

mkdir -p /etc/framewave

CFGGEN_PARAMS=" \
    -d \
    -y /etc/sonic/constants.yml \
"
sonic-cfggen $CFGGEN_PARAMS

mkdir -p /var/sonic
echo "# Config files managed by sonic-config-engine" > /var/sonic/config_status

rm -f /var/run/rsyslogd.pid

supervisorctl start rsyslogd

rm -f /var/log/bgp/*

# Start framewave processes
supervisorctl start nbased
supervisorctl start ymm
supervisorctl start fcmd
supervisorctl start fspd
supervisorctl start ftnmd
supervisorctl start fimd
