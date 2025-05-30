#!/bin/bash

function loading() {
  for i in {1..3}; do
    echo -ne "\r💿💿💿💿 Sedang diproses"
    sleep 0.3
    echo -ne "\r            "
    sleep 0.3
  done
}

echo "Pilih ukuran swap yang ingin Anda pasang:"
echo "1) 1GB"
echo "2) 2GB"
echo "3) 3GB"
echo "4) 4GB"
echo "5) 6GB"
read -p "Masukkan pilihan Anda (1-5): " pilihan

case $pilihan in
  1) ukuran=1G ;;
  2) ukuran=2G ;;
  3) ukuran=3G ;;
  4) ukuran=4G ;;
  5) ukuran=6G ;;
  *) echo "Pilihan tidak valid."; exit 1 ;;
esac

echo -e "\n💿💿💿💿 Membuat swap sebesar $ukuran...\n"
loading

# Nonaktifkan swap lama jika ada
sudo swapoff -a
loading

# Hapus file swap lama jika ada
sudo rm -f /swapfile
loading

# Membuat file swap baru
if sudo fallocate -l $ukuran /swapfile; then
  echo "Swap file berhasil dibuat dengan fallocate."
else
  echo "fallocate gagal, mencoba menggunakan dd..."
  sudo dd if=/dev/zero of=/swapfile bs=1M count=$(echo $ukuran | sed 's/G//')000 status=progress
fi
loading

# Atur permission
sudo chmod 600 /swapfile
loading

# Format swap
sudo mkswap /swapfile
loading

# Aktifkan swap
sudo swapon /swapfile
loading

# Tambahkan ke fstab agar aktif saat boot
if ! grep -q "/swapfile" /etc/fstab; then
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi
loading

# Tuning opsi sistem
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50

# Simpan konfigurasi permanen
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.d/99-swappiness.conf

echo -e "\n✅ Swap $ukuran berhasil dipasang dan diaktifkan!"
