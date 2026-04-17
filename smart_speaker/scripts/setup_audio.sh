#!/bin/bash

# Skrypt konfigurujący PulseAudio i parametry dźwięku dla inteligentnego głośnika

# 1. Instalacja niezbędnych bibliotek
sudo apt-get update
sudo apt-get install -y pulseaudio pavucontrol libasound2-dev

# 2. Ustawienia głośności dla PulseAudio
# Po podłączeniu DAC/Wzmacniacza należy ustawić go jako domyślne urządzenie:
# pacmd set-default-sink 0
# pacmd set-sink-volume 0 52428 # ok. 80%

# 3. Jeśli używasz PWM audio z GPIO, dodaj to do config.txt (później):
# dtoverlay=audremap,pins_18_19

# 4. Sprawdzenie, czy urządzenie wejściowe (mikrofon) jest widoczne:
echo "Wpisz 'arecord -l', aby zobaczyć podłączone mikrofony po ich podpięciu."

# 5. Jeśli używasz Pipewire (nowsze systemy RPi OS), PulseAudio może być emulowane.
# Warto sprawdzić status usługi:
# systemctl --user status pulseaudio
