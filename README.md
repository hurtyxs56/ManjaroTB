# ManjaroTB — ETS2 / TrucksBook (diagnostyka)

Skrypt `install.sh` przygotowuje podstawowe narzędzia i sprawdza Steam, prefix ETS2 w Proton oraz procesy gry i TrucksBook.

## Jedna komenda

```bash
bash -c 'set -e; f=$(mktemp); curl -fsSL https://raw.githubusercontent.com/hurtyxs56/ManjaroTB/main/install.sh -o "$f"; bash "$f"; rm -f "$f"'
```

Przed uruchomieniem skryptu pobieranego z Internetu można przeczytać jego zawartość w repozytorium.

## Dalsza konfiguracja

1. Zainstaluj ETS2 przez Steam.
2. We Właściwościach ETS2 → Zgodność wymuś Proton, aby uruchomić Windowsową wersję gry.
3. Uruchom ETS2 przynajmniej raz w Protonie.
4. Pobierz klienta TrucksBook z oficjalnej strony https://trucksbook.eu/.
5. Sprawdź zgodność instalatora i wtyczki telemetrii z Wine/Proton; nie zakładaj, że samo uruchomienie procesu oznacza rejestrowanie tras.

**Ograniczenia:** skrypt nie instaluje TrucksBook ani Steam Tinker Launch; nie konfiguruje automatycznie jego telemetrii i nie gwarantuje zapisywania przejazdów. Nie symuluje tras.
