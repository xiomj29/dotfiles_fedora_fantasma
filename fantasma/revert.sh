#!/usr/bin/env bash
set -uo pipefail
RICE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BK="$RICE/backup"

cs="$(cat "$BK/colorscheme.txt" 2>/dev/null || true)"; [ -z "$cs" ] && cs="BreezeDark"
plasma-apply-colorscheme "$cs" >/dev/null 2>&1

acc="$(cat "$BK/accent.txt" 2>/dev/null || true)"
if [ -n "$acc" ]; then
  kwriteconfig6 --file kdeglobals --group General --key AccentColor "$acc"
else
  kwriteconfig6 --file kdeglobals --group General --key AccentColor --delete 2>/dev/null || true
  kwriteconfig6 --file kdeglobals --group General --key LastUsedCustomAccentColor --delete 2>/dev/null || true
fi

prof="$(cat "$BK/konsoleprofile.txt" 2>/dev/null || true)"
[ -n "$prof" ] && kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "$prof"

ico="$(cat "$BK/icontheme.txt" 2>/dev/null || true)"; [ -z "$ico" ] && ico="breeze-dark"
kwriteconfig6 --file kdeglobals --group Icons --key Theme "$ico"

cr="$(cat "$BK/cornerradius.txt" 2>/dev/null || true)"
if [ -n "$cr" ]; then
  kwriteconfig6 --file breezerc --group Common --key CornerRadius "$cr"
else
  kwriteconfig6 --file breezerc --group Common --key CornerRadius --delete 2>/dev/null || true
fi

echo "Revertido → esquema: $cs, accent: ${acc:-por defecto}, iconos: $ico."
echo "Los widgets del escritorio, el wallpaper y la línea de ~/.zshrc quedan;"
echo "bórralos a mano si quieres (widgets desde el escritorio; busca 'Fantasma' en ~/.zshrc)."
