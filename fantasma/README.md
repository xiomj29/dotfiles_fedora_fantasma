# 幻 Fantasma

Rice cyberpunk para KDE Plasma 6 / Wayland (Fedora). Fondos oscuros de color
(no negro puro), acentos desaturados, sin glow. Kanji tema: 幻 (ilusión / fantasma).

## Paleta

| Rol      | Hex |
|----------|-----|
| Fondo    | `#121019` |
| Rosa     | `#ff7fb8` |
| Violeta  | `#c88ff0` (accent) |
| Cian     | `#3ad6e6` |
| Texto    | `#e6e0ea` |

## Uso

```bash
./apply.sh     # aplica todo (idempotente; guarda backup la primera vez)
./revert.sh    # vuelve al estado anterior
```

## Qué incluye

- `color-schemes/` esquema de Plasma (Dolphin y apps KDE lo heredan)
- `konsole/` colorscheme + perfil (JetBrainsMono NF, opacidad 0.72, blur)
- `starship/` + `zshrc.fantasma` prompt
- `wallpaper/` Glitch Phantom (SVG fuente + PNG 4K)
- `aurorae/` decoración de ventanas
- `look-and-feel/` Tema Global (fija esquema + iconos entre sesiones)
- `widgets/plasmoids/` clock, frame, vinyl y vitals (monitor con ondas en vivo)
- `widgets/bin/fantasma-stats` helper de datos para vitals
- `sddm/` tema de login (avatar circular, reloj)
- Iconos Papirus-Dark con carpetas violeta, wallpaper de escritorio y lock screen,
  ajustes de Dolphin y Konsole por defecto

Regenerar el wallpaper tras editar el SVG:

```bash
rsvg-convert -w 3840 -h 2160 wallpaper/fantasma-glitch.svg -o wallpaper/fantasma-glitch.png
```

## Requisitos

Plasma 6 en Wayland, `curl`, `rsvg-convert`, fuente `Noto Sans CJK JP`.
