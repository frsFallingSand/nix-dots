{ pkgs
, ...
}:

# Network, locale, input method, and console configuration.

{
  networking.hostName = "qqxnkrut"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  networking.proxy.default = "http://127.0.0.1:7897/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-lua
      fcitx5-gtk
      fcitx5-nord
      fcitx5-pinyin-zhwiki
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
    ];
    fcitx5.waylandFrontend = true;
  };

  console = {
    font = "default8x16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  networking.nameservers = [
    "192.168.0.99"
    "223.5.5.5"
  ];
  # networking.networkmanager.dns = "systemd-resolved";
  networking.networkmanager.insertNameservers = [
    "192.168.0.99"
    "223.5.5.5"
  ];
}
