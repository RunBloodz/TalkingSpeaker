#!/bin/bash

# Skrypt instalujący fbcp (Framebuffer Copy)
# Pozwala na kopiowanie obrazu z głównego pulpitu (fb0) na mały ekran SPI (fb1)

echo "=== Instalacja FBCP (Mirroring obrazu) ==="

# 1. Instalacja zależności
sudo apt-get update
sudo apt-get install -y cmake git

# 2. Pobranie i kompilacja fbcp
cd /tmp
git clone https://github.com/tasanakorn/rpi-fbcp
cd rpi-fbcp
mkdir build
cd build
cmake ..
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
