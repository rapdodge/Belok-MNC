#!/bin/sh

# Membaca nama file dari user
file_name=$1

# Mengecek apakah file exists
if [ ! -f $file_name ]; then
  echo "File $file_name tidak ditemukan!"
  exit 1
fi

# Membaca setiap baris pada file
while read line; do
  # Melakukan curl pada URL yang ada pada baris
  server=$(curl -sSf --connect-timeout 1 -I "http://$IP" 2>/dev/null | awk -F ': ' 'tolower($1) == "server" { print $2 }')
  echo $line
  echo $server
done < $file_name
