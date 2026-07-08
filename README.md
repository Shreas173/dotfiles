# NixOS Dotfiles

Declarative NixOS configuration with **niri** compositor, **quickshell** bar, **wallust** auto color scheme, **fuzzel** launcher, **macOS cursors**, and more.

## Prerequisites

- **NixOS 26.05+** — installed via the standard ISO
- **Git** — for cloning this repo
- **Sudo** — for `nixos-rebuild`
- **Internet** — Nix needs to download packages

## Fresh NixOS installation

### 1. Install NixOS

Follow the standard [NixOS installation guide](https://nixos.org/manual/nixos/stable/#sec-installation) up to the `nixos-install` step.

### 2. Clone this repo

```bash
cd ~
git clone https://github.com/Shreas173/dotfiles
cd dotfiles
```

### 3. Generate hardware config

This is the **only** machine-specific file — it detects disks, GPU, and kernel modules for your hardware:

```bash
sudo nixos-generate-config --show-hardware-config > system/hardware.nix
```

### 4. Build and switch

```bash
sudo nixos-rebuild switch --flake .#nixos
```

This builds and activates everything:
- System config (bootloader, kernel, display manager, networking)
- Home Manager (user packages, config files, environment variables, services)
- All dotfiles deployed to `~/.config/`

### 5. Reboot

```bash
sudo reboot
```

On next login, niri starts with the wallpaper bar, cursors, and all keybinds ready.

### 6. Set wallpaper and colors (post-reboot)

```bash
wallust run ~/Downloads/wall.png -q
```

This extracts colors from your wallpaper and updates the niri background, bar theme, and UI accent colors.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  ~/dotfiles/                     │
│                                                   │
│  flake.nix ──┬── system/configuration.nix        │
│              │         (boot, kernel, GDM, niri) │
│              │                                   │
│              └── home/default.nix                │
│                      ├── home.packages           │
│                      ├── home.sessionVariables   │
│                      ├── xdg.configFile          │
│                      │     ├── niri/config.kdl ──► niri compositor
│                      │     ├── quickshell/* ─────► QML bar
│                      │     ├── fuzzel/* ─────────► app launcher
│                      │     └── wallust-config/* ─► wallust engine
│                      └── systemd.user.services   │
│                                                   │
│  Run-time (not managed by Nix):                  │
│    WallustTheme.qml ◄── wallust run ← wallpaper  │
│    colors.kdl ◄──────────┘                       │
└─────────────────────────────────────────────────┘
```

### How the pieces connect

| Component | Role | Config location | Managed by |
|-----------|------|-----------------|------------|
| **niri** | Wayland compositor | `home/dotfiles/niri/config.kdl` | Home Manager |
| **quickshell** | Status bar | `home/dotfiles/quickshell/` (22 QML files) | Home Manager |
| **wallust** | Color extraction | `home/wallust-config/` (config + Jinja2 templates) | Home Manager |
| **fuzzel** | App launcher | `home/dotfiles/fuzzel/` | Home Manager |
| **swaybg** | Wallpaper daemon | Started by niri | Runtime |
| **apple-cursor** | macOS cursors | `home/default.nix` → `home.packages` | Home Manager |

### Dynamic color pipeline

```
wallpaper → wallust run → colors.kdl (niri live-reloads)
                       → WallustTheme.qml (bar reads on restart)
```

`colors.kdl` and `WallustTheme.qml` are **not** managed by Nix — they're generated at runtime by wallust so they update with every wallpaper change.

---

## Directory structure

```
~/dotfiles/
├── flake.nix                   # Flake entry (system + home-manager)
├── flake.lock
├── README.md
├── system/
│   ├── configuration.nix       # NixOS: boot, kernel, GDM, niri.enable, network
│   └── hardware.nix            # Machine-specific (regenerate per machine)
├── home/
│   ├── default.nix             # Home Manager entry
│   ├── dotfiles/
│   │   ├── niri/config.kdl     # niri keybinds, blur, opacity, cursor, etc.
│   │   ├── quickshell/         # Full QML bar config
│   │   │   ├── shell.qml
│   │   │   ├── Theme.qml       # Singleton with Rose Pine + dynamic wallust fallback
│   │   │   └── bar/            # 20+ QML widgets
│   │   └── fuzzel/             # Catppuccin Mocha Blue theme
│   │       ├── fuzzel.ini
│   │       └── catppuccin-mocha-blue.ini
│   └── wallust-config/
│       ├── wallust.toml        # Template declarations
│       └── templates/
│           ├── niri.kdl        # → colors.kdl (niri bg, focus-ring, border)
│           └── qs-theme.qml    # → WallustTheme.qml (bar colors)
└── .config/opencode/skills/nixos-dotfiles/SKILL.md  # Auto-loaded by opencode
```

---

## Post-install tasks

### First login

When you first log in, set your wallpaper and generate colors:

```bash
# Copy your wallpaper to ~/Downloads/wall.png
cp /path/to/your/wallpaper.png ~/Downloads/wall.png

# Extract colors and apply
wallust run ~/Downloads/wall.png -q
```

The wallpaper and bar should appear immediately. If the bar doesn't show, start it:

```bash
QML_IMPORT_PATH=/nix/store/knxc2lffak0vqn9607ijcmhq804ipakk-qt5compat-6.11.1/lib/qt-6/qml quickshell &
```

### Changing wallpaper

```bash
# 1. Replace the file
cp ~/new-wallpaper.jpg ~/Downloads/wall.png

# 2. Update colors and wallpaper
wallust run ~/Downloads/wall.png -q
pkill swaybg; swaybg -i ~/Downloads/wall.png -m fill &
pkill quickshell; sleep 0.5; QML_IMPORT_PATH=... quickshell &
```

### Re-running color scheme only

```bash
wallust run ~/Downloads/wall.png -q
```

This updates `colors.kdl` (niri live-reloads it) and `WallustTheme.qml` (quickshell picks it up on restart).

---

## Key bindings

| Key | Action |
|-----|--------|
| `Mod+T` | Open terminal (ghostty) |
| `Mod+D` | App launcher (fuzzel) |
| `Mod+Space` | App launcher (fuzzel) |
| `Mod+Q` | Close focused window |
| `Mod+O` | Toggle overview |
| `Mod+F` | Maximize column |
| `Mod+M` | Maximize window to edges |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+1–9` | Focus workspace by index |
| `Mod+Ctrl+1–9` | Move column to workspace |
| `Mod+Left/Right` | Focus column |
| `Mod+Up/Down` | Focus window in column |
| `Mod+H/J/K/L` | Vim-style focus (left/down/up/right) |
| `Mod+Shift+E` | Quit niri |
| `Mod+W` | Toggle tabbed column |
| `Mod+V` | Toggle floating |
| `Mod+Shift+P` | Power off monitors |
| `Mod+Esc` | Toggle shortcuts inhibitor (for VMs) |
| `Print` | Screenshot full screen |
| `Ctrl+Print` | Screenshot focused screen |
| `Alt+Print` | Screenshot focused window |

`Mod` = Super (Windows key) on TTY, Alt when running as a window.

---

## Customization

### Adding a package

Open `home/default.nix`, add to the `home.packages` list:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  your-package
];
```

Then rebuild:

```bash
cd ~/dotfiles && git pull
sudo nixos-rebuild switch --flake .#nixos
```

### Changing niri settings

Edit `home/dotfiles/niri/config.kdl` directly — it's a symlink managed by Nix. After editing, rebuild:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

The config change takes effect on next niri restart.

### Changing bar theme colors

The bar uses wallust-generated colors by default. To switch to a static theme, edit `home/dotfiles/quickshell/Theme.qml` and change:

```qml
property Item get: wallust  // change to: rosePine, catppuccin, nordic, etc.
```

### Changing the launcher theme

Edit `home/dotfiles/fuzzel/fuzzel.ini`. The Catppuccin Mocha Blue include is at `catppuccin-mocha-blue.ini` in the same directory.

### Adding a new quickshell widget

1. Create the QML file in `home/dotfiles/quickshell/bar/blocks/`
2. Add `xdg.configFile."quickshell/bar/blocks/YourWidget.qml".source = ./dotfiles/quickshell/bar/blocks/YourWidget.qml;` to `home/default.nix`
3. Rebuild

---

## Troubleshooting

### Quickshell bar disappeared

```bash
pkill quickshell  # kill if running
QML_IMPORT_PATH=/nix/store/knxc2lffak0vqn9607ijcmhq804ipakk-qt5compat-6.11.1/lib/qt-6/qml quickshell &
```

If it doesn't start, check the log:

```bash
ls -t ~/.cache/quickshell/logs/ | head -1 | xargs -I{} cat ~/.cache/quickshell/logs/{}
```

### Wallpaper not showing

```bash
pkill swaybg
swaybg -i ~/Downloads/wall.png -m fill &
```

### Home Manager activation failed (files would be clobbered)

Remove the conflicting files and rebuild:

```bash
rm -f ~/.config/systemd/user/wallpaper-changer.* ~/.config/systemd/user/timers.target.wants/wallpaper-changer.timer
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

### Nix build fails with "does not exist in Git repository"

Stage new files with git:

```bash
cd ~/dotfiles
git add -A
git commit -m "Add new files"
sudo nixos-rebuild switch --flake .#nixos
```

---

## Updating

```bash
cd ~/dotfiles
git pull
sudo nixos-rebuild switch --flake .#nixos
```

This updates both the system and Home Manager configurations.

---

## Portability

To use on another machine:

```bash
git clone https://github.com/Shreas173/dotfiles ~/dotfiles
cd ~/dotfiles
sudo nixos-generate-config --show-hardware-config > system/hardware.nix
sudo nixos-rebuild switch --flake .#nixos
```

Only `system/hardware.nix` changes per machine — everything else is portable.

---

## License

MIT
