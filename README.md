# NixOS Dotfiles

Declarative NixOS configuration with **niri** compositor, **quickshell** bar, **wallust** color scheme engine, **fuzzel** launcher, and more.

## Quick start on a new machine

```bash
# 1. Clone this repo
git clone https://github.com/Shreas173/dotfiles ~/dotfiles
cd ~/dotfiles

# 2. Generate hardware config for your machine
sudo nixos-generate-config --show-hardware-config > system/hardware.nix

# 3. Build and switch
sudo nixos-rebuild switch --flake .#nixos

# 4. Reboot
sudo reboot
```

## Post-install

After rebooting, set your wallpaper and generate the color scheme:

```bash
wallust run ~/Downloads/wall.png -q
```

The wallpaper and bar start automatically on login via niri's startup config.

To update colors after changing the wallpaper, run:
```bash
wallust run ~/Downloads/wall.png -q
```

## Structure

```
~/dotfiles/
├── flake.nix               # Flake entry — system + home-manager
├── flake.lock
├── system/
│   ├── configuration.nix   # NixOS: bootloader, kernel, GDM, niri.enable, network
│   └── hardware.nix        # Machine-specific (the only file to change per machine)
├── home/
│   ├── default.nix         # Home Manager entry — packages, config files, env vars
│   ├── dotfiles/niri/config.kdl   # niri compositor config
│   ├── dotfiles/quickshell/       # QML bar config (shell.qml, Theme.qml, bar/)
│   ├── dotfiles/fuzzel/           # App launcher config
│   └── wallust-config/            # wallust config + Jinja2 templates
└── README.md
```

## What's included

| Component | Description |
|-----------|-------------|
| **niri** | Wayland compositor with blur, transparency, focus-follows-mouse |
| **quickshell** | QML-based bar with workspaces, system tray, clock, sound |
| **wallust** | Automatic color extraction from wallpaper → niri + bar theme |
| **fuzzel** | rofi-style app launcher with Catppuccin Mocha Blue theme |
| **swaybg** | Wallpaper daemon |
| **macOS cursors** | Apple-style cursor theme via `apple-cursor` |
| **ghostty / alacritty** | Terminal emulators |

## Key bindings

| Key | Action |
|-----|--------|
| `Mod+T` | Open terminal (ghostty) |
| `Mod+D` | App launcher (fuzzel) |
| `Mod+Space` | App launcher (fuzzel) |
| `Mod+Q` | Close window |
| `Mod+O` | Toggle overview |
| `Mod+F` | Maximize column |
| `Mod+1–9` | Switch workspace |

## Updating

```bash
cd ~/dotfiles
git pull
sudo nixos-rebuild switch --flake .#nixos
```

## For developers

To extend this config:

1. **Add a package**: add to `home.packages` in `home/default.nix`
2. **Add a config file**: add source to `home/dotfiles/` and link it via `xdg.configFile` in `home/default.nix`
3. **Wallpaper colors**: edit templates in `home/wallust-config/templates/`
4. **niri settings**: edit `home/dotfiles/niri/config.kdl`
