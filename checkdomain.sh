#!/bin/bash

# Check if the correct number of arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <domain> <ip_address> <url>"
  exit 1
fi

domain="$1"
ip_address="$2"
url="$3"

# Construct the curl command
echo $ip_address
curl --resolve "$domain:443:$ip_address" "$url" 2>/dev/null -I | head -n 1 | cut -d$' ' -f2
echo

# Exit with success
exit 0
