#!/bin/bash

echo "=== Diagnostyka Ekranu ==="

# 1. Sprawdzenie czy SPI jest włączone w kernelu
lsmod | grep spi

# 2. Sprawdzenie czy sterownik ili9341 został załadowany
dmesg | grep ili9341
dmesg | grep ads7846

# 3. Sprawdzenie czy powstał nowy framebuffer (powinien być /dev/fb1)
ls -l /dev/fb*

# 4. Sprawdzenie konfiguracji boot
echo "--- Fragment /boot/config.txt ---"
grep -E "dtoverlay=ili9341|dtoverlay=ads7846|dtparam=spi" /boot/config.txt || grep -E "dtoverlay=ili9341|dtoverlay=ads7846|dtparam=spi" /boot/firmware/config.txt

echo "--- Sprawdzenie vc4-kms-v3d ---"
grep "vc4-kms-v3d" /boot/config.txt || grep "vc4-kms-v3d" /boot/firmware/config.txt

echo "=========================="
echo "Jeśli /dev/fb1 istnieje, spróbuj wysłać tam testowy obraz:"
echo "sudo cat /dev/urandom > /dev/fb1"
echo "Jeśli ekran zareaguje (śnieżenie), to znaczy że driver działa, a problemem jest brak kopiowania obrazu z pulpitu."
