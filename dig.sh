#!/bin/bash

# Membaca nama file dari user
file_name=$1

# Mengecek apakah file exists
if [ ! -f "$file_name" ]; then
  echo "File '$file_name' tidak ditemukan!"
  exit 1
fi

# Menghitung total baris dalam file
total_lines=$(wc -l < "$file_name")
line_count=0

# Array untuk menyimpan hasil dig (jika ada)
declare -A results

# Membaca setiap baris pada file dan melakukan dig, hanya menampilkan progress
while read line; do
  line_count=$((line_count + 1))
  percentage=$(( (line_count * 100) / total_lines ))

  # Membuat progress bar sederhana
  progress_bar="["
  progress_width=20
  filled_width=$(( (percentage * progress_width) / 100 ))
  for ((i=0; i<filled_width; i++)); do
    progress_bar+="="
  done
  for ((i=filled_width; i<progress_width; i++)); do
    progress_bar+=" "
  done
  progress_bar+="]"

  # Menampilkan progress bar pada baris yang sama
  printf "\rProgress: %3d%% %s (%d/%d)" "$percentage" "$progress_bar" "$line_count" "$total_lines"

  # Melakukan dig pada URL yang ada pada baris
  dig_output=$(dig A +short "$line" @8.8.8.8)

  # Menyimpan hasil dig jika ada output
  if [ -n "$dig_output" ]; then
    results["$line"]="$dig_output"
  fi

done < "$file_name"

# Mencetak baris baru setelah progress 100%
echo ""

# Mencetak hasil dig yang berhasil
echo "--- Hasil ---"
if [[ -z "${!results[@]}" ]]; then
  echo "Tidak ada output dig yang ditemukan."
else
  for line in "${!results[@]}"; do
    echo "$line"
    echo "${results["$line"]}"
  done
fi
