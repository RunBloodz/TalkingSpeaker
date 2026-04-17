#!/bin/bash
# Adres IP Home Assistant (zmień na swój!)
HA_URL="http://homeassistant.local:8123"

# Wyłączenie wygaszania ekranu i oszczędzania energii
xset s noblank
xset s off
xset -dpms

# Ukrycie kursora myszy
unclutter -idle 0.1 -root &

# Czekamy na sieć
sleep 10

# Uruchomienie Chromium w trybie Kiosk
# --app= uruchamia stronę bez pasków narzędzi
# --kiosk wymusza pełny ekran
# --disable-restore-session-state zapobiega komunikatom o błędnym zamknięciu
# --noerrdialogs ukrywa błędy
chromium-browser --kiosk --app=$HA_URL --noerrdialogs --disable-infobars --check-for-update-interval=31536000 --disable-session-crashed-bubble --disable-restore-session-state
