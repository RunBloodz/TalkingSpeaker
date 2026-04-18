# Inteligentny Głośnik na Raspberry Pi 3B

Projekt inteligentnego głośnika zintegrowanego z Home Assistant, wykorzystujący ekran dotykowy SPI oraz zewnętrzny wzmacniacz audio.

## Schemat podłączenia (Pinout)

Poniżej znajduje się tabela połączeń dla ekranu **TJCTM24024-SPI (ILI9341)** z panelem dotykowym oraz sugerowane piny dla audio i mikrofonu.

### 1. Ekran i Dotyk (Złącze SPI)

| Pin na ekranie | Pin na RPi (Physical) | Nazwa pinu RPi | Opis |
| :--- | :--- | :--- | :--- |
| **VCC** | 2 lub 4 | 5V | Zasilanie (zalecane 5V) |
| **GND** | 6, 9, 14, 20... | GND | Masa |
| **CS (Display)** | 24 | GPIO 8 (CE0) | Chip Select dla ekranu |
| **RESET** | 36 | GPIO 27 | Reset (można zmienić w skrypcie) |
| **DC/RS** | 22 | GPIO 25 | Data/Command |
| **SDI (MOSI)** | 19 | GPIO 10 (MOSI) | Dane SPI |
| **SCK** | 23 | GPIO 11 (SCLK) | Zegar SPI |
| **LED** | 1 lub 17 | 3.3V | Podświetlenie (można przez rezystor) |
| **SDO (MISO)** | 21 | GPIO 9 (MISO) | Dane zwrotne SPI |
| **T_CLK** | 23 | GPIO 11 (SCLK) | Zegar SPI (wspólny) |
| **T_CS** | 26 | GPIO 7 (CE1) | Chip Select dla dotyku |
| **T_DIN** | 19 | GPIO 10 (MOSI) | Dane SPI (wspólne) |
| **T_DO** | 21 | GPIO 9 (MISO) | Dane zwrotne SPI (wspólne) |
| **T_IRQ** | 11 | GPIO 17 | Przerwanie dotyku |

### 2. Audio (Gdy tata przyniesie wzmacniacz)

Jeśli używasz wzmacniacza I2S (np. MAX98357A):
- **LRCK** -> GPIO 19 (Pin 35)
- **BCLK** -> GPIO 18 (Pin 12)
- **DIN**  -> GPIO 21 (Pin 40)
- **VIN**  -> 5V
- **GND**  -> GND

Jeśli używasz wyjścia PWM (prostszy wzmacniacz na jack/GPIO):
- **Audio Right** -> GPIO 13
- **Audio Left**  -> GPIO 12

### 3. Mikrofon
- **USB**: Po prostu wepnij w dowolny port USB.
- **I2S**: Wymaga dodatkowej konfiguracji pinów (zazwyczaj GPIO 18, 19, 20).

---

## Instrukcja instalacji

1. Skonfiguruj ekran i dotyk:
   ```bash
   chmod +x smart_speaker/scripts/setup_display.sh
   sudo ./smart_speaker/scripts/setup_display.sh
   ```
2. Zoptymalizuj system:
   ```bash
   chmod +x smart_speaker/scripts/optimize_system.sh
   sudo ./smart_speaker/scripts/optimize_system.sh
   ```
3. Skonfiguruj Kiosk (Przeglądarkę):
   ```bash
   chmod +x smart_speaker/scripts/setup_kiosk.sh
   ./smart_speaker/scripts/setup_kiosk.sh
   ```
   *Pamiętaj o edycji `~/start_kiosk.sh` i wpisaniu adresu IP Twojego Home Assistant!*

4. Skonfiguruj audio:
   ```bash
   chmod +x smart_speaker/scripts/setup_audio.sh
   ./smart_speaker/scripts/setup_audio.sh
   ```

Po wykonaniu kroków 1 i 2 wymagany jest restart: `sudo reboot`.

## Konfiguracja Home Assistant (YAML)

Po uruchomieniu ekranu i przeglądarki, musisz skonfigurować wygląd swojego głośnika w Home Assistant.
Pełny poradnik krok po kroku znajdziesz w pliku: **[smart_speaker/HA_TUTORIAL_PL.md](smart_speaker/HA_TUTORIAL_PL.md)**.
