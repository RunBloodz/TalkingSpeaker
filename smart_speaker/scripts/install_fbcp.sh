#!/bin/bash

# Skrypt instalujący fbcp (Framebuffer Copy)
# Pozwala na kopiowanie obrazu z głównego pulpitu (fb0) na mały ekran SPI (fb1)

echo "=== Instalacja FBCP (Mirroring obrazu) ==="

# 1. Instalacja zależności
sudo apt-get update
sudo apt-get install -y cmake git libraspberrypi-dev raspberrypi-kernel-headers

# 2. Pobranie i kompilacja fbcp
cd /tmp
rm -rf rpi-fbcp
git clone https://github.com/tasanakorn/rpi-fbcp
cd rpi-fbcp
mkdir build
cd build

# Poprawka dla brakujących nagłówków bcm_host.h (ścieżki w nowszych systemach)
export CFLAGS="-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux"
export LDFLAGS="-L/opt/vc/lib"

cmake -DCMAKE_INCLUDE_PATH="/opt/vc/include" -DCMAKE_LIBRARY_PATH="/opt/vc/lib" ..
make
sudo install fbcp /usr/local/bin/fbcp

# 3. Dodanie fbcp do autostartu
# Tworzymy prosty serwis systemowy
cat <<EOF | sudo tee /etc/systemd/system/fbcp.service
[Unit]
Description=Framebuffer copy utility for SPI displays
After=display-manager.service

[Service]
ExecStart=/usr/local/bin/fbcp
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 4. Uruchomienie serwisu
sudo systemctl daemon-reload
sudo systemctl enable fbcp
sudo systemctl start fbcp

echo "=== Gotowe! ==="
echo "Jeśli obraz na małym ekranie jest teraz widoczny, to znaczy że wszystko działa."
echo "Jeśli obraz jest 'rozjechany' lub kolory są dziwne, daj znać."
