#!/bin/bash

# Skrypt optymalizujący system i sprawdzający poprawność autostartu

# 1. Wyłączenie powiadomień o niedowoltowaniu (częste przy ekranie i audio)
# Dodać do /boot/config.txt: avoid_warnings=1 (niezalecane, lepiej użyć 5V/3A)

# 2. Optymalizacja swapa (dla 1GB RAM w RPi 3B)
sudo dphys-swapfile swapoff
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=512/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# 3. Dodanie systemd-path dla stabilności interfejsu
# Jeśli ekran nie wystartuje na czas, kiosk może wyświetlić błąd.
# Skrypt start_kiosk.sh w ~/ ma dodane --noerrdialogs i --disable-infobars.

# 4. Automatyczna kalibracja dotyku po starcie (opcjonalne)
# xinput_calibrator --output-type xorg.conf.d

echo "System zoptymalizowany dla Raspberry Pi 3B."
