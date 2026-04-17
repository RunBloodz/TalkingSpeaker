#!/bin/bash

# Skrypt przygotowujący Raspberry Pi do obsługi ekranu ILI9341 i dotyku

echo "=== Konfiguracja ekranu TJCTM24024-SPI (ILI9341) ==="

# 1. Włączenie SPI
sudo raspi-config nonint do_spi 0

# 2. Dodanie nakładki do /boot/config.txt (lub /boot/firmware/config.txt w nowszych systemach)
CONFIG_PATH="/boot/config.txt"
if [ ! -f "$CONFIG_PATH" ]; then
    CONFIG_PATH="/boot/firmware/config.txt"
fi

echo "Edycja $CONFIG_PATH..."

# Backup
sudo cp $CONFIG_PATH "${CONFIG_PATH}.bak"

# Wyłączenie Full KMS, który często powoduje biały ekran na małych wyświetlaczach SPI
sudo sed -i 's/dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/g' $CONFIG_PATH
sudo sed -i 's/dtoverlay=vc4-fkms-v3d/#dtoverlay=vc4-fkms-v3d/g' $CONFIG_PATH

# Dodanie konfiguracji dla wyświetlacza i dotyku
# Zakładamy standardowe podpięcie:
# CS=GPIO8, DC=GPIO25, RESET=GPIO27
# Dotyk: CS=GPIO7, IRQ=GPIO17
cat <<EOF | sudo tee -a $CONFIG_PATH

# Konfiguracja ekranu ILI9341
# Ustawienie bcm2835-leds zapobiega białemu ekranowi przy starcie
dtparam=spi=on
dtoverlay=ili9341,speed=32000000,fps=30,rotation=90,reset_pin=27,dc_pin=25
# Konfiguracja dotyku XPT2046
dtoverlay=ads7846,penirq=17,handle_irq=1,cs=1,speed=2000000,keep_vref_on=0,swapxy=0,pmax=255,xohms=150,xmin=200,xmax=3900,ymin=200,ymax=3900
EOF

echo "Konfiguracja dopisana. Po restarcie ekran powinien przestać być biały i pokazać konsolę lub czarny obraz."

# 3. Instalacja narzędzi do kalibracji i obsługi
sudo apt-get update
sudo apt-get install -y xinput-calibrator xserver-xorg-input-evdev

# 4. Przekierowanie obrazu z fb0 na fb1 (jeśli chcemy widzieć pulpit)
# Do płynnego działania na RPi 3B zaleca się fbcp-ili9341, ale na start sprawdzimy podstawy.
# sudo apt-get install -y cmake
# [Tu można dodać kompilację fbcp-ili9341 w przyszłości]

echo "Gotowe! Uruchom ponownie Raspberry Pi komendą: sudo reboot"
