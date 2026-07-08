{ config, pkgs, inputs, ... }:

let
  editorFont = "Fira Code";
  editorFontSize = "12";

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
    jq
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

    starship
    zsh

    rcp
    wallpaper-script
  ];

  home.sessionVariables = {
    XCURSOR_THEME = "macOS";
    XCURSOR_SIZE = "24";
    QML_IMPORT_PATH = "${pkgs.qt6.qt5compat}/lib/qt-6/qml";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;
  };

  xdg.configFile = {
    "niri/config.kdl".source = ./dotfiles/niri/config.kdl;
    "fuzzel/fuzzel.ini".source = ./dotfiles/fuzzel/fuzzel.ini;
    "fuzzel/catppuccin-mocha-blue.ini".source = ./dotfiles/fuzzel/catppuccin-mocha-blue.ini;
    "geany/geany.conf" = { source = ./dotfiles/geany/geany.conf; force = true; };
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

    "ghostty/config.ghostty" = { source = ./dotfiles/ghostty/config.ghostty; force = true; };

    "fastfetch/config.jsonc" = { source = ./dotfiles/fastfetch/config.jsonc; force = true; };

    "starship.toml" = { source = ./dotfiles/starship.toml; force = true; };

    "kitty/kitty.conf" = { source = ./dotfiles/kitty/kitty.conf; force = true; };
    "kitty/quick-access-terminal.conf" = { source = ./dotfiles/kitty/quick-access-terminal.conf; force = true; };

    "nvim/lua/options.lua" = {
      force = true;
      text = ''
        require "nvchad.options"

        local o = vim.o
        o.tabstop = 4
        o.shiftwidth = 4
        o.expandtab = true

        vim.opt.guifont = "${editorFont}:h${editorFontSize}"
      '';
    };
  };

}
