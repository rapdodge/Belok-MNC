#!/bin/sh

# Define the IP range to ping
IP_RANGE="xxx.xxx.xxx."

# Loop through the range of IPs and ping each one
for i in $(seq 1 254)
do
  IP="$IP_RANGE$i"
  server=$(curl -sSf --connect-timeout 1 -I "http://$IP" 2>/dev/null | awk -F ': ' 'tolower($1) == "server" { print $2 }')
  if ping -c 1 -W 1 "$IP" >/dev/null 2>&1; then
    echo "IP $IP responded"
    echo $server
  else
    echo "IP $IP did not respond"
    echo $server
  fi
done
