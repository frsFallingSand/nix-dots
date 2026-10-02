{ lib
, pkgs
, ...
}:

# Desktop, Wayland, session environment, and fonts.

{
  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
    enable = true;
    # windowManager.qtile.enable = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = false;
    xwayland.enable = true;
    # package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # package = hypr;
  };

  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "hyprland";
  services.desktopManager.gnome.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.sessionVariables.GDK_GL = "gles";

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  hardware.bluetooth.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cups-pdf-to-pdf ];

  # Enable sound.
  services.pulseaudio.enable = false;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  programs.niri = {
    enable = true;
  };
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  security.pam.services.swaylock = { };
  # programs.waybar.enable = true; # top bar
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  environment.sessionVariables = {
    # Wayland 优化与输入法环境变量
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    XIM_SERVERS = "fcitx";
    # 修复 fcitx5 插件未被发现：让 GUI 会话能找到系统共享数据目录
    XDG_DATA_DIRS = lib.mkDefault [
      "/run/current-system/sw/share"
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];
    # From End4's hyprland dotfiles
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "kde";
    XDG_MENU_PREFIX = "plasma-";
    TERMINAL = "kitty -1";
    ILLOGICAL_IMPULSE_VIRTUAL_ENV = "~/.local/state/quickshell/.venv";

    # From QQ Group
    DISPLAY = ":0";
    XDG_CURRENT_DESKTOP = "hyprland";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";

    # From MorningMC (NvidiaSupport)
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    AQ_NO_MODESET = "1";

    # LD_LIBRARY
    # LD_LIBRARY_PATH = [
    #   "/run/current-system/sw/lib"
    #   "/run/opengl-driver/lib"
    # ];

    # drivers path
    LIBGL_DRIVERS_PATH = "/run/opengl-driver/lib";
  };

  fonts = {
    fontDir.enable = true; # 启用旧版字体路径兼容
    packages = with pkgs; [
      material-symbols
      cascadia-code
      noto-fonts
      noto-fonts-cjk-sans # 思源黑体
      noto-fonts-cjk-serif # 思源宋体
      noto-fonts-color-emoji
      source-han-sans # 思源黑体
      nerd-fonts.noto
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [
          "Noto Sans CJK SC"
          "DejaVu Sans"
        ];
        serif = [
          "Noto Serif CJK SC"
          "DejaVu Serif"
        ];
        monospace = [
          "Cascadia Code"
          "Noto Sans Mono CJK SC"
        ];
      };
    };
  };
}
