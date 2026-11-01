#!/usr/bin/env bash
set -Eeuo pipefail
APPID=227300
DIR="$HOME/.local/share/manjarotb"
mkdir -p "$DIR"
log(){ printf '\n[ManjaroTB] %s\n' "$*"; }
fail(){ echo "BLAD: $*" >&2; exit 1; }
command -v pacman >/dev/null || fail "Wymagany Manjaro/Arch."
command -v steam >/dev/null || log "Steam nie jest w PATH (Flatpak nie jest obslugiwany)."
if ! command -v protontricks-launch >/dev/null; then
  log "Proba instalacji protontricks z oficjalnego repozytorium..."
  sudo pacman -S --needed protontricks || fail "Brak protontricks w repozytorium. Zainstaluj go z zaufanego zrodla i ponow."
fi
command -v protontricks-launch >/dev/null || fail "Brak protontricks-launch."
PREFIX=""
for root in "$HOME/.local/share/Steam" "$HOME/.steam/steam" /run/media/"$USER"/*/SteamLibrary /mnt/*/SteamLibrary; do
  if [[ -d "$root/steamapps/compatdata/$APPID/pfx" ]]; then PREFIX="$root/steamapps/compatdata/$APPID"; break; fi
done
if [[ -z "$PREFIX" ]]; then
  for base in /run/media/"$USER" /mnt "$HOME/.local/share/Steam" "$HOME/.steam"; do
    [[ -d "$base" ]] || continue
    while IFS= read -r -d '' found; do
      PREFIX="${found%/pfx}"
      break
    done < <(find "$base" -maxdepth 8 -type d -path "*/steamapps/compatdata/$APPID/pfx" -print0 2>/dev/null)
    [[ -n "$PREFIX" ]] && break
  done
fi
if [[ -z "$PREFIX" ]]; then
  echo "Nie znaleziono prefixu automatycznie."
  read -r -p "Podaj pelna sciezke do katalogu pfx ETS2 (lub Enter, aby przerwac): " CUSTOM_PFX
  [[ -n "$CUSTOM_PFX" && -d "$CUSTOM_PFX/drive_c" ]] || fail "Nie znaleziono prawidlowego katalogu pfx."
  PREFIX="${CUSTOM_PFX%/pfx}"
fi
log "Prefix ETS2: $PREFIX"
if [[ -z "${TB_SETUP:-}" ]]; then
  echo "Pobierz klienta z https://trucksbook.eu/ po zalogowaniu i rozpakuj archiwum."
  read -r -p "Podaj pelna sciezke do setup.exe TrucksBook (Enter, jesli juz zainstalowany): " TB_SETUP
fi
if [[ -n "$TB_SETUP" ]]; then
  [[ -f "$TB_SETUP" ]] || fail "Brak instalatora: $TB_SETUP"
  log "Uruchamiam instalator w prefixie ETS2. Wybierz poprawny plik eurotrucks2.exe."
  protontricks-launch --appid "$APPID" "$TB_SETUP"
fi
TB_EXE=""
while IFS= read -r -d '' file; do TB_EXE="$file"; break; done < <(find "$PREFIX/pfx/drive_c" -type f -iname 'TB Client.exe' -print0 2>/dev/null)
[[ -n "$TB_EXE" ]] || fail "Nie znaleziono TB Client.exe w prefixie ETS2. Zainstaluj klienta w tym prefixie."
printf '%s\n' "$TB_EXE" > "$DIR/client-path"
cat > "$DIR/launch.sh" <<'EOF'
#!/usr/bin/env bash
set -u
CLIENT="$(cat "$HOME/.local/share/manjarotb/client-path")"
if [[ -f "$CLIENT" ]] && command -v protontricks-launch >/dev/null; then
  protontricks-launch --appid 227300 "$CLIENT" >"$HOME/.local/share/manjarotb/trucksbook.log" 2>&1 &
  sleep 12
fi
if [[ "$#" -eq 0 ]]; then echo "Uruchom ten skrypt przez opcje uruchamiania Steam z %command%." >&2; exit 1; fi
exec "$@"
EOF
chmod +x "$DIR/launch.sh"
log "Gotowe. W Steam > ETS2 > Wlasciwosci > Ogolne > Opcje uruchamiania wklej:"
echo "\"$DIR/launch.sh\" %command%"
echo "Upewnij sie, ze w zakladce Zgodnosc jest wybrany Proton."
echo "Zaloguj sie do TrucksBook, sprawdz sciezke gry i wykonaj testowe zlecenie."
echo "Log: $DIR/trucksbook.log"
echo "Nie gwarantujemy zapisu tras; wymaga sprawnego pluginu telemetrii TrucksBook."
