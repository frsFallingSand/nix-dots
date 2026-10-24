{
  pkgs,
  ...
}:

# Power, portals, and application services.

{
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.mihomo.tunMode = true;

  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = false;
      dates = "weekly";
      extraArgs = "--keep 20 --keep-since 42d";
    };
    # 设置 NH_OS_FLAKE 变量
    flake = "/home/admin/workspace/nix-config";
  };

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  # Hyprland already adds xdg-desktop-portal-hyprland through
  # programs.hyprland. Keep GTK as the generic fallback and KDE available
  # for the explicit FileChooser preference in the user's portals.conf.
  # Do not select xdg-desktop-portal-wlr: it is not the correct backend
  # for Hyprland and may fail to initialize screencasting.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
    config.hyprland.default = [
      "hyprland"
      "gtk"
    ];
  };

  programs.virt-manager.enable = true;
  programs.dconf.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
    plugins = with pkgs.obs-studio-plugins; [
      input-overlay
      looking-glass-obs
      obs-media-controls
      obs-pipewire-audio-capture
      obs-backgroundremoval
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
      waveform
      wlrobs
    ];
  };

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        # 空列表会让 Kanata 自动扫描并拦截本机所有接入的键盘
        devices = [ ];

        # 必须开启：让未被 defsrc 声明的其余所有按键正常直通
        extraDefCfg = "process-unmapped-keys yes";

        config = ''
          (defsrc
            caps h j k l w b u x c
          )

          (defalias
            cap (tap-hold-press 200 200 esc (layer-toggle nav))
          )

          (deflayer base
            @cap h j k l w b u x c
          )

          (deflayer nav
            _    left down up right C-right C-left C-z del caps
          )
        '';
      };
    };
  };
}
