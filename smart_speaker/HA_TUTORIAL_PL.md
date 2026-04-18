# Tutorial: Konfiguracja Dashboardu Home Assistant dla Głośnika

Ten poradnik pomoże Ci stworzyć idealny interfejs na Twój mały ekran 240x320, który zawiera zegar i przycisk asystenta głosowego (Assist).

## Krok 1: Przygotowanie zasobów
Dla najlepszego efektu zegara polecam zainstalować przez **HACS** kartę `Digital Clock Card` lub `Custom Brand Icons`. Jeśli nie masz HACS, użyjemy standardowych kart.

## Krok 2: Tworzenie nowego Dashboardu
1. W Home Assistant wejdź w **Ustawienia** -> **Pulpity sterownicze**.
2. Kliknij **Dodaj pulpit sterowniczy**.
3. Nazwij go `Głośnik` i wybierz ikonę mikrofonu.

## Krok 3: Konfiguracja YAML (Kopiuj-Wklej)
Kliknij trzy kropki w prawym górnym rogu nowego dashboardu, wybierz **Edytuj pulpit**, a następnie ponownie trzy kropki i **Edytor konfiguracji (Raw configuration editor)**. Usuń wszystko i wklej poniższy kod:

```yaml
views:
  - title: Home
    path: home
    # Panel mode sprawia, że karta zajmuje cały ekran - idealne dla 240x320
    type: panel
    cards:
      - type: vertical-stack
        cards:
          # 1. KARTA ZEGARA
          - type: sensor
            entity: sensor.time # Wymaga integracji 'time_date' w configuration.yaml
            name: " "
            graph: none
            style: |
              ha-card {
                --card-secondary-font-size: 40px;
                height: 100px;
                background: none;
                border: none;
                box-shadow: none;
              }

          # 2. PRZYCISK ASYSTENTA (Główna funkcja)
          - type: button
            name: "Słucham..."
            show_name: true
            show_icon: true
            icon: mdi:google-assistant
            icon_height: 100px
            tap_action:
              action: assist # To otwiera natywne okno asystenta HA
            hold_action:
              action: none
            style: |
              ha-card {
                background: var(--primary-color);
                border-radius: 50px;
                margin: 10px;
                animation: pulse 2s infinite;
              }
              @keyframes pulse {
                0% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0.7); }
                70% { box-shadow: 0 0 0 20px rgba(255, 255, 255, 0); }
                100% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0); }
              }

          # 3. DODATKOWE INFORMACJE (opcjonalnie)
          - type: entity
            entity: sensor.outdoor_temperature
            name: Na zewnątrz
```

## Krok 4: Konfiguracja Assist w Home Assistant
Aby przycisk działał i mówił po polsku:
1. Wejdź w **Ustawienia** -> **Głos**.
2. Upewnij się, że masz skonfigurowany **Pipeline** (Rurociąg) o nazwie "Home Assistant Cloud" lub lokalny (Whisper/Piper).
3. Ustaw język na **Polski**.
4. W sekcji "Conversation agent" wybierz Home Assistant.

## Krok 5: Automatyzacja ekranu (Opcjonalnie)
Możesz sprawić, by ekran się rozjaśniał, gdy ktoś wejdzie do pokoju, dodając automatyzację w HA, która wysyła komendę do Raspberry Pi (wymaga SSH):
- **Wyzwalacz**: Czujnik ruchu.
- **Akcja**: Wykonaj usługę `shell_command` (xset dpms force on).

## Ważne uwagi dla ekranu 240x320:
- Używaj kart typu **Vertical Stack**, aby elementy nie uciekały na boki.
- Wyłącz pasek boczny (Sidebar) w ustawieniach profilu użytkownika na Raspberry Pi ("Zawsze ukrywaj pasek boczny"), aby zyskać więcej miejsca.
- W ustawieniach Dashboardu włącz "Tryb Kiosku" (wymaga dodatku `kiosk-mode` z HACS), aby ukryć górny pasek nawigacji.
