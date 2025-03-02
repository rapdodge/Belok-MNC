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
curl --resolve "$domain:443:$ip_address" "$url"

# Exit with success
exit 0
