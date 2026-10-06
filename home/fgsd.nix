{ nvimdotsHMModule
, ...
}:

{
  imports = [
    nvimdotsHMModule
    ./desktop.nix
    ./packages.nix
    ./scripts.nix
  ];

  # Keep dotfiles in the repository while preserving the recursive Hyprland
  # directory behavior used by the existing configuration.
  xdg.configFile."quickshell".source = ../config/quickshell;
  xdg.configFile."hypr" = {
    source = ../config/hypr;
    recursive = true;
  };

  programs.neovim = {
    enable = true;
    withRuby = false;
  };

  programs.neovim.nvimdots = {
    enable = true;
    setBuildEnv = false;
    withBuildTools = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "frsFallingSand";
      user.email = "frsfallingsand@outlook.com";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  home = {
    username = "fgsd";
    homeDirectory = "/home/fgsd";
    stateVersion = "25.11";
  };

  home.sessionVariables = {
    # Wayland and input-method environment variables.
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    XIM_SERVERS = "fcitx";
    XDG_DATA_DIRS = "/run/current-system/sw/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    XDG_CONFIG_HOME = "/home/fgsd/.config";
    XDG_DATA_HOME = "/home/fgsd/.local/share";
    XDG_CACHE_HOME = "/home/fgsd/.cache";
    XDG_STATE_HOME = "/home/fgsd/.local/state";

    # Wayland desktop defaults inherited from the existing dotfiles.
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "kde";
    XDG_MENU_PREFIX = "plasma-";
    TERMINAL = "kitty -1";
    ILLOGICAL_IMPULSE_VIRTUAL_ENV = "~/.local/state/quickshell/.venv";

    DISPLAY = ":0";
    XDG_CURRENT_DESKTOP = "hyprland";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";

    # NVIDIA/Hyprland session variables.
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    AQ_NO_MODESET = "1";
    LIBGL_DRIVERS_PATH = "/run/opengl-driver/lib";

    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
