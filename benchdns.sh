#!/bin/bash

# Cek apakah file IP DNS diberikan sebagai argumen
if [ -z "$1" ]; then
  echo "Penggunaan: ./digspeed <file_ip.txt>"
  exit 1
fi

# File input yang berisi daftar IP DNS
file_ip="$1"

# Domain yang akan di-dig
domain="www.facebook.com"

# File temporary untuk menyimpan hasil ping dan DNS Server
temp_file="hasil_ping_temp.txt"
> "$temp_file" # Kosongkan file jika sudah ada

# Loop melalui setiap IP DNS dari file
while IFS= read -r dns_server <&3; do
  echo "Memproses DNS Server: $dns_server"

  # Proses dig
  dig_output=$(/root/tools/belok-mnc/q --timeout=3s +short A "$domain" @"$dns_server" 2>/dev/null)

  # Ambil IP pertama dari hasil dig
  ip_target=$(echo "$dig_output" | grep -v '\.$' | head -n 1)

  # Cek apakah dig menghasilkan IP
  if [ -z "$ip_target" ]; then
    echo "Tidak ada respon IP dari dig untuk DNS Server: $dns_server"
    rtt="N/A"
  else
    echo "IP Target dari dig: $ip_target"

    # Proses ping ke IP pertama
    ping_output=$(ping -c 1 "$ip_target" 2>/dev/null)
#    echo "=== OUTPUT PING ==="
#    echo "$ping_output"
#    echo "=== END OUTPUT PING ==="

    # Ekstrak nilai rtt dari hasil ping (ambil nilai min)
    rtt=$(echo "$ping_output" | grep "rtt min/avg/max" | awk -F'=' '{print $2}' | awk -F'/' '{print $1}' | tr -d ' ')

    # Cek apakah ping berhasil mendapatkan rtt
    if [ -z "$rtt" ]; then
      echo "Tidak dapat memperoleh nilai RTT dari ping ke $ip_target menggunakan DNS Server $dns_server"
      rtt="N/A"
    else
      echo "RTT: $rtt ms"
    fi
  fi

  # Simpan hasil ke file temporary dengan format: RTT DNS_SERVER
  echo "$rtt $dns_server" >> "$temp_file"

done 3< "$file_ip"

# Lakukan sorting hasil ping berdasarkan RTT dari terendah ke tertinggi
echo "----- Hasil Ping yang Diurutkan (RTT terendah ke tertinggi) -----"
sort -n "$temp_file" | while IFS= read -r sorted_line; do
  sorted_rtt=$(echo "$sorted_line" | awk '{print $1}')
  sorted_dns_server=$(echo "$sorted_line" | awk '{$1=""; print $0}' | sed 's/^ //')

  # Tampilkan hasil yang sudah diurutkan
  if [ "$sorted_rtt" = "N/A" ]; then
    echo "DNS Server: $sorted_dns_server, RTT: $sorted_rtt"
  else
    echo "DNS Server: $sorted_dns_server, RTT: $sorted_rtt ms"
  fi
done

# Bersihkan file temporary
rm "$temp_file"

echo "----------------------------------------------------"

exit 0
