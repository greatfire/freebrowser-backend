#!/bin/bash

# Run cron
cron &

# Start dnsmasq
dnsmasq --port=5353 --server=8.8.8.8 --server=8.8.4.4 &
# Add for debugging: --log-queries --log-facility=/opt/fbnginx/logs/dnsmasq.log

# Start Nginx in the foreground
exec nginx -g 'daemon off;'
