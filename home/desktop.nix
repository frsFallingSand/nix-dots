{ pkgs, hypr, ... }:

# Home Manager desktop integration: portals, fonts, and Hyprland.

{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      kdePackages.xdg-desktop-portal-kde
    ];
    # The following seems to generate ~/.config/xdg-desktop-portal conflicting with the one under dots/
    #config.hyprland = {
    #  default = [ "hyprland" "gtk" ];
    #  "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    #};
  };
  # Note: The following generate files under ~/.config/fontconfig/conf.d/
  # fontconfig may rely on this to properly find fonts installed via Nix.
  fonts.fontconfig.enable = true;

  wayland.windowManager.hyprland = {
    ## Make sure home-manager not generate ~/.config/hypr/hyprland.conf
    systemd.enable = false;
    plugins = [ ];
    settings = { };
    extraConfig = "";
    enable = true;
    ## Use NixGL
    # package = config.lib.nixGL.wrap pkgs.hyprland;
    package = hypr;
    # package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    configType = "lua";
  };
}
