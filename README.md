# dotfiles — 幻 Fantasma

Rice para Fedora KDE Plasma 6 (Wayland) + neko.

```
fantasma/      rice completo: widgets QML (clock, frame, vinyl, vitals),
               aurorae, color-scheme, konsole, starship, look-and-feel,
               sddm, wallpapers, apply.sh / revert.sh
bin/neko       gatito pixel art (PyQt6)
autostart/     neko.desktop
kwin/          regla de ventana para el neko
applications/  lanzadores extra
```

## Instalación

```bash
sudo dnf install -y zsh papirus-icon-theme bat fzf zoxide
pip install pyqt6 --break-system-packages

cd fantasma && ./apply.sh

cp bin/neko ~/.local/bin/neko && chmod +x ~/.local/bin/neko
mkdir -p ~/.config/autostart && cp autostart/neko.desktop ~/.config/autostart/
```

`apply.sh` aplica todo: tema, iconos, ventanas, terminal, widgets, wallpaper,
lock screen, Dolphin y SDDM (pide sudo solo para el login).

## Notas

- La geometría de los widgets está pensada para 1536×864; en otra resolución se deben ajustar.
- El avatar del SDDM lee `/var/lib/AccountsService/icons/<usuario>`; edita `sddm/themes/fantasma/Main.qml` para cambiar el usuario.
- La barra de título toma su color tras cerrar sesión una vez.
