#!/usr/bin/env bash
set -Eeuo pipefail
APP=227300
STATE="$HOME/.local/share/manjarotb"
mkdir -p "$STATE"
LOG="$STATE/install.log"
exec > >(tee -a "$LOG") 2>&1
trap 'echo "[BLAD] Linia $LINENO. Log: $LOG"' ERR
say(){ printf '\n[ManjaroTB] %s\n' "$*"; }
die(){ say "BLAD: $*"; exit 1; }
command -v pacman >/dev/null || die "Wymagany Manjaro/Arch."
command -v protontricks-launch >/dev/null || { say "Instalacja Protontricks..."; sudo pacman -S --needed protontricks || die "Brak pakietu protontricks w repozytorium."; }
command -v curl >/dev/null || sudo pacman -S --needed curl
say "Wyszukiwanie ETS2 na wszystkich typowych dyskach..."
PFX=""
for base in "$HOME/.local/share/Steam" "$HOME/.steam/steam" /run/media/"$USER" /mnt; do
  [[ -d "$base" ]] || continue
  while IFS= read -r -d '' found; do PFX="$found"; break; done < <(find "$base" -maxdepth 9 -type d -path "*/steamapps/compatdata/$APP/pfx" -print0 2>/dev/null)
  [[ -n "$PFX" ]] && break
done
[[ -n "$PFX" ]] || die "Brak prefixu ETS2. W Steam wymus Proton, uruchom gre raz, zamknij."
COMPAT="${PFX%/pfx}"
LIB="${COMPAT%/steamapps/compatdata/$APP}"
say "Znaleziono ETS2: $COMPAT"
# Steam client library metadata is still required by protontricks; keep its default discovery.
if pgrep -afi 'eurotrucks2.exe|eurotrucks2' >/dev/null; then die "Zamknij ETS2 przed instalacja."; fi
TB=""
while IFS= read -r -d '' f; do TB="$f"; break; done < <(find "$PFX/drive_c" -type f -iname 'TB Client.exe' -print0 2>/dev/null)
if [[ -z "$TB" ]]; then
  say "Szukam pobranego oryginalnego instalatora TrucksBook..."
  SETUP=""
  for base in "$HOME/Downloads" "$HOME/Pobrane" "$HOME/Desktop" "$HOME/Pulpit"; do
    [[ -d "$base" ]] || continue
    while IFS= read -r -d '' f; do SETUP="$f"; break; done < <(find "$base" -maxdepth 5 -type f \( -iname 'setup*.exe' -o -iname '*trucksbook*.exe' \) -print0 2>/dev/null)
    [[ -n "$SETUP" ]] && break
  done
  if [[ -z "$SETUP" ]]; then
    say "Pobierz oryginalny instalator z https://trucksbook.eu/ po zalogowaniu, rozpakuj ZIP."
    if command -v zenity >/dev/null; then SETUP="$(zenity --file-selection --title='Wybierz setup.exe TrucksBook' || true)"; else read -r -p "Pelna sciezka do setup.exe: " SETUP; fi
  fi
  [[ -f "$SETUP" ]] || die "Nie wybrano prawidlowego setup.exe. Nic nie usunieto."
  say "Uruchamiam instalator TrucksBook w prefixie ETS2..."
  STEAM_COMPAT_DATA_PATH="$COMPAT" protontricks-launch --appid "$APP" "$SETUP" || die "Instalator zakonczyl sie bledem. Sprawdz $LOG"
  while IFS= read -r -d '' f; do TB="$f"; break; done < <(find "$PFX/drive_c" -type f -iname 'TB Client.exe' -print0 2>/dev/null)
fi
[[ -f "$TB" ]] || die "Nie znaleziono TB Client.exe po instalacji. Sprawdz, czy instalator zakonczyl sie poprawnie."
printf '%s\n' "$TB" > "$STATE/client-path"
printf '%s\n' "$COMPAT" > "$STATE/compat-path"
cat > "$STATE/launch.sh" <<'LAUNCH'
#!/usr/bin/env bash
# Fail open: ETS2 starts even when TrucksBook fails.
STATE="$HOME/.local/share/manjarotb"
if [[ "$#" -eq 0 ]]; then echo "Wymagany parametr %command%"; exit 1; fi
TB="$(cat "$STATE/client-path" 2>/dev/null)"
COMPAT="$(cat "$STATE/compat-path" 2>/dev/null)"
if [[ -f "$TB" ]] && command -v protontricks-launch >/dev/null; then
  (STEAM_COMPAT_DATA_PATH="$COMPAT" protontricks-launch --appid 227300 "$TB" >>"$STATE/trucksbook.log" 2>&1) &
fi
exec "$@"
LAUNCH
chmod +x "$STATE/launch.sh"
say "Instalacja klienta zakonczona. NIE zmieniam automatycznie opcji Steam."
say "W Steam -> ETS2 -> Wlasciwosci -> Ogolne -> Opcje uruchamiania wklej:"
printf '"%s/launch.sh" %%command%%\n' "$STATE"
say "W TrucksBook ustaw poprawna sciezke do eurotrucks2.exe i sprawdz wtyczke telemetrii."
say "Nie jest mozliwe potwierdzenie rejestrowania tras bez testowej dostawy."
