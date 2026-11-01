#!/usr/bin/env bash
set -Eeuo pipefail
echo "=== Manjaro ETS2 / TrucksBook diagnostics ==="
if ! command -v pacman >/dev/null; then echo "Ten skrypt wymaga Manjaro/Arch."; exit 1; fi
echo "Instalowanie narzedzi z repozytoriow systemowych..."
sudo pacman -S --needed --noconfirm curl unzip
echo
echo "Steam: $(command -v steam || echo 'nie znaleziono')"
echo "Protontricks: $(command -v protontricks || echo 'nie znaleziono')"
for base in "$HOME/.local/share/Steam" "$HOME/.steam/steam" "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"; do
  if [[ -d "$base/steamapps" ]]; then
    echo "Biblioteka: $base"
    [[ -d "$base/steamapps/compatdata/227300" ]] && echo "Znaleziono prefix Proton ETS2: $base/steamapps/compatdata/227300"
  fi
done
echo
echo "Procesy ETS2/TrucksBook:"
pgrep -afi 'eurotrucks2|trucksbook' || true
echo
echo "W Steam wymus Windowsowa wersje ETS2 przez Proton."
echo "TrucksBook musi byc uruchomiony w zgodnym prefixie i korzystac z wtyczki telemetrii gry."
echo "Ten skrypt nie instaluje klienta TrucksBook i nie zapewnia automatycznego naliczania tras."
