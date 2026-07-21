#!/usr/bin/env bash
set -uo pipefail

RICE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BK="$RICE/backup"
ACCENT_RGB="200,143,240"
ACCENT_HEX="#c88ff0"

WM_ACTIVE_BG="181,133,222"
WM_ACTIVE_FG="20,16,30"
WM_ACTIVE_BLEND="255,127,184"
WM_INACTIVE_BG="26,22,36"
WM_INACTIVE_BLEND="32,24,42"
WM_INACTIVE_FG="150,142,170"

PLASMOIDS=(org.fantasma.vinyl org.fantasma.clock org.fantasma.frame org.fantasma.stats)
GEO_VINYL="1088,64,400,176,0"
GEO_CLOCK="0,495.938,672,368,0"
GEO_FRAME="1088,288,400,224,0"
GEO_STATS="1088,536,400,240,0"

QDBUS="$(command -v qdbus || command -v qdbus-qt6 || command -v qdbus6 || true)"

say(){ printf '\n\033[1;35m> %s\033[0m\n' "$1"; }
ok(){  printf '  \033[1;32m+\033[0m %s\n' "$1"; }
warn(){ printf '  \033[1;33m!\033[0m %s\n' "$1"; }

if [ ! -f "$BK/done" ]; then
  say "Guardando estado actual para poder revertir..."
  kreadconfig6 --file kdeglobals --group General --key ColorScheme      > "$BK/colorscheme.txt" 2>/dev/null || true
  kreadconfig6 --file kdeglobals --group General --key AccentColor      > "$BK/accent.txt"      2>/dev/null || true
  kreadconfig6 --file kdeglobals --group Icons   --key Theme            > "$BK/icontheme.txt"   2>/dev/null || true
  kreadconfig6 --file breezerc   --group Common  --key CornerRadius     > "$BK/cornerradius.txt" 2>/dev/null || true
  kreadconfig6 --file konsolerc  --group "Desktop Entry" --key DefaultProfile > "$BK/konsoleprofile.txt" 2>/dev/null || true
  touch "$BK/done"
  ok "Backup en $BK"
fi

say "Instalando esquema, Konsole, starship y wallpaper..."
mkdir -p ~/.local/share/color-schemes ~/.local/share/konsole \
         ~/.local/share/wallpapers/Fantasma ~/.config ~/.local/bin ~/.local/share/fonts \
         ~/.local/share/plasma/plasmoids ~/.local/share/plasma/look-and-feel \
         ~/.local/share/aurorae/themes
cp "$RICE/color-schemes/Fantasma.colors"     ~/.local/share/color-schemes/
rm -rf ~/.local/share/plasma/look-and-feel/org.fantasma.desktop
cp -r "$RICE/look-and-feel/org.fantasma.desktop" ~/.local/share/plasma/look-and-feel/
rm -rf ~/.local/share/aurorae/themes/fantasma
cp -r "$RICE/aurorae/themes/fantasma"        ~/.local/share/aurorae/themes/
cp "$RICE/konsole/Fantasma.colorscheme"      ~/.local/share/konsole/
cp "$RICE/konsole/Fantasma.profile"          ~/.local/share/konsole/
cp "$RICE/starship/starship.toml"            ~/.config/starship.toml
cp "$RICE/wallpaper/fantasma.png"            ~/.local/share/wallpapers/Fantasma/
cp "$RICE/wallpaper/fantasma-glitch.png"     ~/.local/share/wallpapers/Fantasma/
ok "Archivos copiados"

if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  say "Descargando JetBrainsMono Nerd Font..."
  tmp="$(mktemp -d)"
  if curl -fL --retry 2 -o "$tmp/JBM.tar.xz" \
       https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz 2>/dev/null; then
    mkdir -p ~/.local/share/fonts/JetBrainsMonoNF
    tar -xf "$tmp/JBM.tar.xz" -C ~/.local/share/fonts/JetBrainsMonoNF
    fc-cache -f >/dev/null 2>&1
    ok "Nerd Font instalada"
  else
    warn "Sin conexión: la terminal usará 'Noto Sans Mono'. Reejecuta con internet para los iconos."
    sed -i 's/JetBrainsMono Nerd Font/Noto Sans Mono/' ~/.local/share/konsole/Fantasma.profile
  fi
  rm -rf "$tmp"
else
  ok "Nerd Font ya presente"
fi

if ! command -v starship >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/starship" ]; then
  say "Instalando starship..."
  if curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" >/dev/null 2>&1; then
    ok "starship instalado"
  else
    warn "No se pudo instalar starship (sin internet). Instálalo luego: 'curl -sS https://starship.rs/install.sh | sh'"
  fi
else
  ok "starship ya presente"
fi

say "Configurando el prompt en ~/.zshrc..."
ZRC="$HOME/.zshrc"; touch "$ZRC"
if ! grep -q 'starship init zsh' "$ZRC"; then
  {
    echo ''
    echo '# Fantasma prompt'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo 'export STARSHIP_CONFIG="$HOME/.config/starship.toml"'
    echo 'command -v starship >/dev/null && eval "$(starship init zsh)"'
  } >> "$ZRC"
  ok "Prompt añadido a ~/.zshrc"
else
  ok "El prompt ya estaba en ~/.zshrc"
fi

say "Iconos Papirus-Dark con carpetas violeta..."
if [ ! -d "$HOME/.local/share/icons/Papirus-Dark" ]; then
  if curl -fsSL https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh \
       | DESTDIR="$HOME/.local/share/icons" sh >/dev/null 2>&1; then
    ok "Papirus instalado en ~/.local/share/icons"
  else
    warn "No se pudo instalar Papirus (sin internet). Instálalo y reejecuta."
  fi
else
  ok "Papirus ya presente"
fi
if [ ! -x "$HOME/.local/bin/papirus-folders" ]; then
  curl -fsSL https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders \
       -o "$HOME/.local/bin/papirus-folders" 2>/dev/null \
    && chmod +x "$HOME/.local/bin/papirus-folders" \
    && ok "papirus-folders instalado" \
    || warn "No se pudo bajar papirus-folders"
fi
if [ -d "$HOME/.local/share/icons/Papirus-Dark" ] && [ -x "$HOME/.local/bin/papirus-folders" ]; then
  "$HOME/.local/bin/papirus-folders" -C violet -t Papirus-Dark >/dev/null 2>&1 \
    && ok "Carpetas violeta" || warn "papirus-folders falló"
fi
kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
ok "Tema de iconos = Papirus-Dark"

say "Decoración de ventana (barra violeta, esquinas rectas)..."
kwriteconfig6 --file kdeglobals --group WM --key activeBackground   "$WM_ACTIVE_BG"
kwriteconfig6 --file kdeglobals --group WM --key activeForeground   "$WM_ACTIVE_FG"
kwriteconfig6 --file kdeglobals --group WM --key activeBlend        "$WM_ACTIVE_BLEND"
kwriteconfig6 --file kdeglobals --group WM --key inactiveBackground "$WM_INACTIVE_BG"
kwriteconfig6 --file kdeglobals --group WM --key inactiveBlend      "$WM_INACTIVE_BLEND"
kwriteconfig6 --file kdeglobals --group WM --key inactiveForeground "$WM_INACTIVE_FG"
kwriteconfig6 --file breezerc   --group Common --key CornerRadius 0
ok "Barra de título violeta + CornerRadius=0"

say "Instalando widgets (vinyl, clock, frame, stats)..."
mkdir -p ~/.local/bin
install -m 755 "$RICE/widgets/bin/fantasma-stats" ~/.local/bin/fantasma-stats
for p in "${PLASMOIDS[@]}"; do
  src="$RICE/widgets/plasmoids/$p"
  [ -d "$src" ] || { warn "falta $p en el repo"; continue; }
  if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -qx "$p"; then
    kpackagetool6 --type Plasma/Applet --upgrade "$src" >/dev/null 2>&1 || cp -rf "$src" ~/.local/share/plasma/plasmoids/
  else
    kpackagetool6 --type Plasma/Applet --install "$src" >/dev/null 2>&1 || cp -rf "$src" ~/.local/share/plasma/plasmoids/
  fi
done
ok "Paquetes de widgets instalados"

say "Tema de login SDDM (Fantasma)..."
if [ -d "$RICE/sddm/themes/fantasma" ]; then
  if sudo -v 2>/dev/null; then
    sudo cp -rT "$RICE/sddm/themes/fantasma" /usr/share/sddm/themes/fantasma
    sudo mkdir -p /etc/sddm.conf.d
    if [ -f /etc/sddm.conf.d/kde_settings.conf ] && grep -q '^Current=' /etc/sddm.conf.d/kde_settings.conf; then
      sudo sed -i 's/^Current=.*/Current=fantasma/' /etc/sddm.conf.d/kde_settings.conf
    else
      printf '[Theme]\nCurrent=fantasma\n' | sudo tee /etc/sddm.conf.d/zz-fantasma.conf >/dev/null
    fi
    ok "SDDM = fantasma (se ve al reiniciar/cerrar sesión)"
  else
    warn "Sin sudo: instala el login a mano →"
    printf '      sudo cp -rT %s/sddm/themes/fantasma /usr/share/sddm/themes/fantasma\n' "$RICE"
    printf '      sudo sed -i "s/^Current=.*/Current=fantasma/" /etc/sddm.conf.d/kde_settings.conf\n'
  fi
fi

say "Aplicando Fantasma al escritorio..."
plasma-apply-lookandfeel -a org.fantasma.desktop >/dev/null 2>&1 \
  && ok "Tema Global Fantasma" || warn "No se pudo aplicar el Tema Global"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__fantasma
ok "Decoración Aurorae 2077"
kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 1
kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 0
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
for i in 1 2 3; do
  plasma-apply-colorscheme Fantasma >/dev/null 2>&1
  [ "$(kreadconfig6 --file kdeglobals --group General --key ColorScheme)" = "Fantasma" ] && break
  sleep 1
done
ok "Esquema de color"
kwriteconfig6 --file kdeglobals --group General --key AccentColor "$ACCENT_RGB"
kwriteconfig6 --file kdeglobals --group General --key LastUsedCustomAccentColor "$ACCENT_RGB"
kwriteconfig6 --file kdeglobals --group WM --key activeBackground "$WM_ACTIVE_BG"
kwriteconfig6 --file kdeglobals --group WM --key activeForeground "$WM_ACTIVE_FG"
ok "Accent violeta + barra violeta reafirmados"
plasma-apply-wallpaperimage "$HOME/.local/share/wallpapers/Fantasma/fantasma-glitch.png" >/dev/null 2>&1 \
  && ok "Wallpaper (Glitch Phantom)" || warn "No se pudo fijar el wallpaper automáticamente (ponlo a mano)"

GLITCH="file://$HOME/.local/share/wallpapers/Fantasma/fantasma-glitch.png"
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "$GLITCH"
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "$GLITCH"
ok "Lock screen con wallpaper Fantasma"

kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "Fantasma.profile"
ok "Perfil de Konsole por defecto"

kwriteconfig6 --file dolphinrc --group MainWindow --key MenuBar "Disabled"
kwriteconfig6 --file dolphinrc --group IconsMode --key PreviewSize 80
ok "Dolphin ajustado"

say "Colocando los widgets en el escritorio..."
RES="$(kscreen-doctor -o 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '/Geometry:/{print $NF; exit}')"
[ -z "$RES" ] && RES="1536x864"
if [ -n "$QDBUS" ]; then
  JS='var d=desktops()[0];
var want=["org.fantasma.vinyl","org.fantasma.clock","org.fantasma.frame","org.fantasma.stats"];
var have={}; var ws=d.widgets();
for(var i=0;i<ws.length;i++){have[ws[i].type]=ws[i].id;}
var ids=[]; var n=0;
for(var j=0;j<want.length;j++){
  if(have[want[j]]===undefined){var w=d.addWidget(want[j]); ids.push(w.id); n++;}
  else{ids.push(have[want[j]]);}
}
print(d.id+"|"+ids.join(",")+"|"+n);'
  OUT="$("$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$JS" 2>/dev/null)"
  if [ -n "$OUT" ] && printf '%s' "$OUT" | grep -q '|'; then
    CONT="${OUT%%|*}"; rest="${OUT#*|}"; IDS="${rest%%|*}"; NADD="${rest##*|}"
    IFS=',' read -r VID CID FID SID <<<"$IDS"
    GEO="Applet-$VID:$GEO_VINYL;Applet-$CID:$GEO_CLOCK;Applet-$FID:$GEO_FRAME;Applet-$SID:$GEO_STATS;"
    APPLETSRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    kwriteconfig6 --file "$APPLETSRC" --group Containments --group "$CONT" --key "ItemGeometries-$RES"   "$GEO"
    kwriteconfig6 --file "$APPLETSRC" --group Containments --group "$CONT" --key "ItemGeometriesHorizontal" "$GEO"
    ok "Widgets en el escritorio (geometría $RES escrita)"
    if [ "${NADD:-0}" != "0" ]; then
      warn "Se añadieron widgets nuevos → reinicio plasmashell para fijar posiciones"
      systemctl --user restart plasma-plasmashell.service 2>/dev/null \
        || { kquitapp6 plasmashell 2>/dev/null; (setsid kstart plasmashell >/dev/null 2>&1 &) ; }
    fi
  else
    warn "No se pudieron añadir por script. Añádelos desde «Añadir widgets» (Vinyl/Clock/Frame)."
  fi
else
  warn "qdbus no disponible: añade los widgets a mano desde «Añadir widgets»."
fi

[ -n "$QDBUS" ] && "$QDBUS" org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true

printf '\n\033[1;35mFantasma aplicado.\033[0m Abre una \033[1mKonsole nueva\033[0m para ver los colores y el prompt.\n'
printf 'Los iconos y la \033[1mbarra de título violeta\033[0m requieren \033[1mcerrar sesión y volver a entrar\033[0m\n'
printf 'una vez (KWin cachea el color de la decoración). Con el Tema Global ya NO se revierte.\n'
printf 'Para revertir todo:  \033[1m%s/revert.sh\033[0m\n\n' "$RICE"
