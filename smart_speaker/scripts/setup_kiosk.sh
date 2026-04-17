#!/bin/bash

# Skrypt konfigurujący przeglądarkę Chromium w trybie Kiosk (dla autologowania do HA)

# 1. Zapewnienie, że Chromium jest zainstalowane
sudo apt-get update
sudo apt-get install -y chromium-browser xdotool unclutter x11-xserver-utils

# 2. Skrypt startowy kiosku
# Kopiujemy gotowy skrypt z folderu projektu do katalogu domowego
cp $(dirname "$0")/start_kiosk.sh ~/start_kiosk.sh
chmod +x ~/start_kiosk.sh

# 3. Dodanie do autostartu środowiska graficznego (LXDE-pi)
# W nowszych wersjach RPi OS ścieżka może być inna: ~/.config/lxsession/LXDE-pi/autostart
AUTOSTART_DIR="$HOME/.config/lxsession/LXDE-pi"
mkdir -p "$AUTOSTART_DIR"
cat <<EOF >> "$AUTOSTART_DIR/autostart"
@bash /home/$USER/start_kiosk.sh
EOF

echo "Skonfigurowano Kiosk dla Chromium. Pamiętaj, aby edytować HA_URL w ~/start_kiosk.sh!"
