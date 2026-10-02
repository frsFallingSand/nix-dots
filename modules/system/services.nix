{ pkgs
, ...
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

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gnome
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gnome
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config.common.default = [ "wlr" ];
    # 移除 gtk/kde 后端避免冲突
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
}
