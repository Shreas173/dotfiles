{ config, pkgs, inputs, ... }:

let
  rcp = pkgs.writeShellScriptBin "rcp" ''
    set -euo pipefail
    if [ $# -ne 1 ]; then
      echo "Usage: rcp <file.cpp>"
      exit 1
    fi
    file="$1"
    if [ ! -f "$file" ]; then
      echo "Error: File '$file' not found."
      exit 1
    fi
    executable="''${file%.cpp}"
    if [ "$executable" = "$file" ]; then
      echo "Warning: Input file does not have .cpp extension, using full name as executable."
    fi
    echo "Compiling $file → $executable"
    g++ -std=c++17 -Wshadow -Wall -o "$executable" "$file" -g -fsanitize=address -fsanitize=undefined -D_GLIBCXX_DEBUG
    echo "Compilation successful! Run with: ./$executable"
  '';

  toggle-dropdown = pkgs.writeShellScriptBin "toggle-dropdown" ''
    set -euo pipefail

    LOCKFILE="/tmp/kitty-dropdown.lock"
    exec 200>"$LOCKFILE"
    flock -n 200 || exit 0

    KITTY_CLASS="kitty-dropdown"
    SOCKET="$XDG_RUNTIME_DIR/kitty-dropdown.sock"
    SCRATCH_WS=99

    focus_out=$(niri msg focused-output 2>/dev/null)
    WIDTH=$(echo "$focus_out" | sed -n 's/.*Logical size: \([0-9]*\)x[0-9]*/\1/p')
    HEIGHT=$(echo "$focus_out" | sed -n 's/.*Logical size: [0-9]*x\([0-9]*\)/\1/p')
    WIDTH=''${WIDTH:-1920}
    HEIGHT=''${HEIGHT:-1080}
    DROP_HEIGHT=$((HEIGHT / 2))

    if ! kitty @ --to "unix:$SOCKET" ls >/dev/null 2>&1; then
      kitty --class "$KITTY_CLASS" --listen-on "unix:$SOCKET" \
        --override remember_window_size=no \
        --override initial_window_width="$WIDTH" \
        --override initial_window_height="$DROP_HEIGHT" \
        --override window_padding_width=12 &
      for _ in $(seq 1 30); do
        if niri msg windows 2>/dev/null | grep -q "$KITTY_CLASS"; then
          niri msg action focus-window "app-id:$KITTY_CLASS" 2>/dev/null || true
          niri msg action move-floating-window --x 0 --y 0 2>/dev/null || true
          break
        fi
        sleep 0.1
      done
      exit 0
    fi

    if niri msg focused-window 2>/dev/null | grep -q "App ID:.*$KITTY_CLASS"; then
      niri msg action move-window-to-workspace "$SCRATCH_WS"
      niri msg action focus-workspace-previous
    else
      current_ws=$(niri msg focused-window 2>/dev/null | grep "Workspace ID" | awk '{print $3}')
      niri msg action focus-window "app-id:$KITTY_CLASS"
      niri msg action move-window-to-workspace "$current_ws"
      niri msg action focus-workspace "$current_ws"
    fi
  '';

  wallpaper-script = pkgs.writeShellScriptBin "random-wallpaper" ''
    wallust run ~/Downloads/wall.png -q
    pkill swaybg 2>/dev/null || true
    swaybg -i ~/Downloads/wall.png -m fill &
    disown
    pkill quickshell 2>/dev/null || true
    sleep 0.5
    QML_IMPORT_PATH=${pkgs.qt6.qt5compat}/lib/qt-6/qml nohup quickshell > /dev/null 2>&1 &
    disown
  '';

in
{
  home.username = "shreas";
  home.homeDirectory = "/home/shreas";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    neovim
    fastfetch
    geany
    obs-studio
    papirus-icon-theme
    kitty
    guake
    ghostty
    discord
    texliveFull
    zathura
    zathuraPkgs.zathura_pdf_poppler
    kdePackages.kdenlive
    bat
    ntfs3g
    alacritty
    gh
    yazi
    ripgrep
    lua51Packages.tree-sitter-cli

    quickshell
    qt6.qt5compat
    fuzzel
    swaybg

    wallust
    apple-cursor
    polkit_gnome

    inputs.helium.packages.${pkgs.system}.default

    rcp
    toggle-dropdown
    wallpaper-script
  ];

  home.sessionVariables = {
    XCURSOR_THEME = "macOS";
    XCURSOR_SIZE = "24";
    QML_IMPORT_PATH = "${pkgs.qt6.qt5compat}/lib/qt-6/qml";
  };

  programs.bash = {
    enable = true;
  };

  xdg.configFile = {
    "niri/config.kdl".source = ./dotfiles/niri/config.kdl;
    "fuzzel/fuzzel.ini".source = ./dotfiles/fuzzel/fuzzel.ini;
    "fuzzel/catppuccin-mocha-blue.ini".source = ./dotfiles/fuzzel/catppuccin-mocha-blue.ini;
    "wallust/wallust.toml".source = ./wallust-config/wallust.toml;
    "wallust/templates/niri.kdl".source = ./wallust-config/templates/niri.kdl;
    "wallust/templates/qs-theme.qml".source = ./wallust-config/templates/qs-theme.qml;

    "quickshell/shell.qml".source = ./dotfiles/quickshell/shell.qml;
    "quickshell/Theme.qml".source = ./dotfiles/quickshell/Theme.qml;
    "quickshell/PopupContext.qml".source = ./dotfiles/quickshell/PopupContext.qml;
    "quickshell/bar/Bar.qml".source = ./dotfiles/quickshell/bar/Bar.qml;
    "quickshell/bar/BarBlock.qml".source = ./dotfiles/quickshell/bar/BarBlock.qml;
    "quickshell/bar/BarText.qml".source = ./dotfiles/quickshell/bar/BarText.qml;
    "quickshell/bar/Notification.qml".source = ./dotfiles/quickshell/bar/Notification.qml;
    "quickshell/bar/NotificationPanel.qml".source = ./dotfiles/quickshell/bar/NotificationPanel.qml;
    "quickshell/bar/Tooltip.qml".source = ./dotfiles/quickshell/bar/Tooltip.qml;
    "quickshell/bar/blocks/ActiveWorkspace.qml".source = ./dotfiles/quickshell/bar/blocks/ActiveWorkspace.qml;
    "quickshell/bar/blocks/Battery.qml".source = ./dotfiles/quickshell/bar/blocks/Battery.qml;
    "quickshell/bar/blocks/Date.qml".source = ./dotfiles/quickshell/bar/blocks/Date.qml;
    "quickshell/bar/blocks/Datetime.qml".source = ./dotfiles/quickshell/bar/blocks/Datetime.qml;
    "quickshell/bar/blocks/Icon.qml".source = ./dotfiles/quickshell/bar/blocks/Icon.qml;
    "quickshell/bar/blocks/Memory.qml".source = ./dotfiles/quickshell/bar/blocks/Memory.qml;
    "quickshell/bar/blocks/Notifications.qml".source = ./dotfiles/quickshell/bar/blocks/Notifications.qml;
    "quickshell/bar/blocks/Sound.qml".source = ./dotfiles/quickshell/bar/blocks/Sound.qml;
    "quickshell/bar/blocks/SystemTray.qml".source = ./dotfiles/quickshell/bar/blocks/SystemTray.qml;
    "quickshell/bar/blocks/Time.qml".source = ./dotfiles/quickshell/bar/blocks/Time.qml;
    "quickshell/bar/blocks/Workspace.qml".source = ./dotfiles/quickshell/bar/blocks/Workspace.qml;
    "quickshell/bar/blocks/Workspaces.qml".source = ./dotfiles/quickshell/bar/blocks/Workspaces.qml;
    "quickshell/bar/utils/HyprlandUtils.qml".source = ./dotfiles/quickshell/bar/utils/HyprlandUtils.qml;
  };

}
