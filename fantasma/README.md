# 幻 Fantasma — rice para KDE Plasma 6

Rice cyberpunk *neo-Tokio* para KDE Plasma 6 / Wayland (Fedora), diseñado para ser
**cómodo con astigmatismo**: fondos oscuros de color (no negro puro), acentos
desaturados y **sin glow**.

Estilo: chasis Cyberpunk 2077 (franja hazard, esquinas cortadas) + interior
neo-Tokio con kanji. Kanji tema: **幻** (*ilusión / fantasma*).

## Paleta

| Rol       | Hex       |
|-----------|-----------|
| Fondo     | `#121019` |
| Superficie| `#20182a` |
| Rosa      | `#ff7fb8` |
| Violeta   | `#c88ff0` (accent) |
| Cian      | `#3ad6e6` |
| Ámbar     | `#eacb52` |
| Texto     | `#e6e0ea` |

## Uso

```bash
./apply.sh     # aplica todo (idempotente)
./revert.sh    # vuelve al estado anterior
```

`apply.sh` es seguro y reversible: guarda tu configuración actual en `backup/`
la primera vez. Instala la Nerd Font y `starship` en `~/.local` (**sin sudo**).

## Qué incluye

- **Esquema de color** de Plasma → `color-schemes/Fantasma.colors`
- **Konsole**: colorscheme + perfil (JetBrainsMono NF, opacidad 0.6, sin blur) → `konsole/`
- **Prompt** starship con `幻`, powerline sin iconos → `starship/starship.toml`
- **Wallpaper** 幻 sobre fondo oscuro → `wallpaper/fantasma.svg` (+ `.png`)
- **Iconos** Papirus-Dark con carpetas violeta (`papirus-folders -C violet`)
- **Decoración de ventana**: tema **Aurorae 幻 2077** → `aurorae/themes/fantasma/`
  (barra violeta plana, trim rosa, esquinas rectas, botones minimalistas).
  Fallback Breeze con barra violeta si se desactiva Aurorae.
- **Widgets 幻** del escritorio → `widgets/plasmoids/` (vinyl · clock · frame · stats),
  instalados con `kpackagetool6` y colocados vía script de Plasma
- **Islas 幻** de la barra superior → `widgets/plasmoids/org.fantasma.islands/`,
  un solo widget QML full-width inspirado en las islas Quickshell de
  [ilyamiro](https://github.com/ilyamiro/nixos-configuration), reescrito para Plasma:
  acciones (幻 → KRunner · ajustes · captura · apagar), workspaces en kanji con
  highlight elástico, reloj + clima (wttr.in) y pills de sistema (CPU · RAM ·
  volumen con rueda · WiFi · BT · batería, via `~/.local/bin/fantasma-islands`).
  Vive en la **capa del escritorio**: las islas son fijas y las ventanas
  maximizadas quedan encima de ellas. (La música vive en el widget vinyl.)
- **Tray propio dentro de las islas**: los iconos StatusNotifier de las apps
  (Spotify, Discover, etc.) se dibujan como pills en su propia isla via
  `StatusNotifierModel`. El click activa por DBus (`fantasma-islands sni`),
  con fallback a MPRIS Raise para items tipo ayatana sin `Activate` (Spotify)
  y a lanzar la app como último recurso. Limitación conocida: los menús
  dbusmenu de items ayatana no se renderizan (eso requiere un host C++).
  Hay además una pill de portapapeles que abre el historial de Klipper. Las
  **notificaciones** son el único applet stock: la campana
  `org.kde.plasma.notifications` como mini-widget al extremo derecho (los
  popups son ventanas propias, así que sí aparecen sobre las apps).
- **Plasma Style Fantasma** → `desktoptheme/Fantasma/`: tema mínimo que solo
  redefine `widgets/background` con el look de las islas (radio 13, ciruela
  translúcido, borde 1px, sin sombra), para que el tray no rompa la vibra.
  Todo lo demás hereda del tema por defecto.
- **5 escritorios virtuales** numerados en kanji: 一 二 三 四 五
- **Accent** violeta y perfil de Konsole por defecto

> Los widgets se colocan con la geometría de una pantalla **1536×864**. En otra
> resolución quizá tengas que reubicarlos a mano la primera vez.

Regenerar el wallpaper tras editar el SVG:

```bash
rsvg-convert -w 3840 -h 2160 wallpaper/fantasma.svg -o wallpaper/fantasma.png
```

## Requisitos

Plasma 6, Wayland, `kwriteconfig6`, `plasma-apply-*` (vienen con KDE),
`Noto Sans CJK JP` (para los kanji), `curl`, `rsvg-convert`.
