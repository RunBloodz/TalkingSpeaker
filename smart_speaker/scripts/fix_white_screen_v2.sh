#!/bin/bash

# Skrypt "Ostatnia Szansa" na biały ekran - próbuje innej metody inicjalizacji

CONFIG_PATH="/boot/config.txt"
if [ ! -f "$CONFIG_PATH" ]; then
    CONFIG_PATH="/boot/firmware/config.txt"
fi

echo "Próbujemy alternatywnej konfiguracji dla czerwonej płytki ILI9341..."

# 1. Kopia zapasowa
sudo cp $CONFIG_PATH "${CONFIG_PATH}.final_bak"

# 2. Usuwamy stare wpisy dot. ili9341
sudo sed -i '/dtoverlay=ili9341/d' $CONFIG_PATH
sudo sed -i '/dtoverlay=ads7846/d' $CONFIG_PATH
sudo sed -i '/dtparam=spi/d' $CONFIG_PATH

# 3. Dodajemy nową konfigurację używając 'rpi-display' - to bardzo stabilna nakładka dla tych ekranów
# rpi-display używa domyślnie:
# CS  -> GPIO 8
# DC  -> GPIO 24 (Zmień kabelek jeśli masz na 25!)
# RES -> GPIO 25 (Zmień kabelek jeśli masz na 27!)
# LED -> GPIO 18

cat <<EOF | sudo tee -a $CONFIG_PATH

# Alternatywna konfiguracja dla ekranu 2.8 SPI
dtparam=spi=on
dtoverlay=rpi-display,speed=16000000,rotate=90
EOF

echo "--- UWAGA ---"
echo "Ta nakładka (rpi-display) wymaga przepięcia dwóch kabelków dla pewności:"
echo "1. DC/RS przepnij do GPIO 24 (Pin 18)"
echo "2. RESET przepnij do GPIO 25 (Pin 22)"
echo "3. LED (jeśli masz) przepnij do GPIO 18 (Pin 12) lub do 3.3V"
echo ""
echo "Jeśli po restarcie ekran nadal jest biały, wykonaj w terminalu:"
echo "dmesg | grep -i graphics"
echo "Pomoże to sprawdzić, czy system w ogóle widzi kontroler."
echo "Zrestartuj teraz: sudo reboot"
