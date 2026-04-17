#!/bin/bash

# Skrypt konfigurujący przeglądarkę Chromium w trybie Kiosk (dla autologowania do HA)

# 1. Zapewnienie, że Chromium jest zainstalowane
sudo apt-get update
sudo apt-get install -y chromium-browser xdotool unclutter x11-xserver-utils

# 2. Skrypt startowy kiosku
mkdir -p ~/.config/autostart
cat <<EOF > ~/start_kiosk.sh
#!/bin/bash
# Adres IP Home Assistant (pobieramy z parametrów, domyślnie localhost)
HA_URL="http://localhost:8123"

# Wyłączenie wygaszania ekranu i oszczędzania energii
xset s noblank
xset s off
xset -dpms

# Ukrycie kursora myszy
unclutter -idle 0.1 -root &

# Uruchomienie Chromium w trybie Kiosk
# --app= uruchamia stronę bez pasków narzędzi
# --kiosk wymusza pełny ekran
# --disable-restore-session-state zapobiega komunikatom o błędnym zamknięciu
# --noerrdialogs ukrywa błędy
chromium-browser --kiosk --app=\$HA_URL --noerrdialogs --disable-infobars --check-for-update-interval=31536000 --disable-session-crashed-bubble --disable-restore-session-state &
EOF

chmod +x ~/start_kiosk.sh

# 3. Dodanie do autostartu środowiska graficznego (LXDE-pi)
# W nowszych wersjach RPi OS ścieżka może być inna: ~/.config/lxsession/LXDE-pi/autostart
AUTOSTART_DIR="$HOME/.config/lxsession/LXDE-pi"
mkdir -p "$AUTOSTART_DIR"
cat <<EOF >> "$AUTOSTART_DIR/autostart"
@bash /home/$USER/start_kiosk.sh
EOF

echo "Skonfigurowano Kiosk dla Chromium. Pamiętaj, aby edytować HA_URL w ~/start_kiosk.sh!"
