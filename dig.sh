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
  dig=$(dig A +short $line @8.8.8.8)
  echo $line
  echo $dig
done < $file_name
