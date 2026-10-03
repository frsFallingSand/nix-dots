{ pkgs, hypr, ... }:

# Home Manager desktop integration: portals, fonts, and Hyprland.

{
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
