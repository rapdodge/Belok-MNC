#!/bin/bash

# Check if a DNS IP list file is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 ip.txt"
  exit 1
fi

dns_file="$1"

# Check if the DNS IP list file exists
if [ ! -f "$dns_file" ]; then
  echo "Error: File '$dns_file' not found."
  exit 1
fi

domain="autopatchhk.yuanshen.com.akamaized.net"  # Domain to resolve

declare -A latencies

while IFS= read -r dns_ip; do
  dns_ip=$(echo "$dns_ip" | tr -d '[:space:]') # Remove whitespace
  if [[ -z "$dns_ip" || "$dns_ip" == "#"* ]]; then # Skip empty/comment lines
      continue
  fi

  resolved_ip=$(dig +short A "$domain" @"$dns_ip" | grep -v '\.$' | head -n 1)

  if [[ -z "$resolved_ip" ]]; then
    echo "Warning: dig to $dns_ip failed for $domain. Skipping."
    continue
  fi

  total_latency=0
  num_pings=5

  for i in $(seq 1 $num_pings); do
    ping -c1 -W1 -q "$resolved_ip" > /dev/null 2>&1

    latency=$(ping -fc5 -W1 "$resolved_ip" | awk '/rtt min\/avg\/max\/mdev/ {print $4}' | cut -d'/' -f2)

    if [[ -z "$latency" ]]; then
      echo "Warning: Ping to $resolved_ip failed. Skipping."
      latency=999999 # Assign large latency for failed pings
      break # Exit the ping loop
    fi

    total_latency=$(bc <<<"$total_latency + $latency")

  done

  average_latency=$(bc <<<"scale=3; $total_latency / $num_pings")

  latencies["$dns_ip"]="$average_latency"

done < "$dns_file"

sorted_ips=()
for ip in "${!latencies[@]}"; do
  sorted_ips+=("${latencies[$ip]}:$ip")
done
sorted_ips=($(sort -n <<<"${sorted_ips[*]}"))

echo "DNS Latency Test Results (Sorted by Latency - Average of $num_pings pings to resolved IP):"
echo "---------------------------------------------------------------------------------------"
for result in "${sorted_ips[@]}"; do
  latency="${result%%:*}"
  ip="${result#*:}"
  echo "DNS Server: $ip, Latency: $latency ms"
done
