# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, dmsNixOSModule, dmsDefaultPkg, quickshellPkg, nP, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      dmsNixOSModule
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelModules = [ "fuse" "kvm-amd" "kvm-intel" "vfio-pci" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.guest.enable = true;

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "loglevel=7"
  ];
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/isos 0755 qemu-libvirtd kvm -"
    "d /var/lib/libvirt/images 0755 qemu-libvirtd kvm -"
  ];

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    powerManagement.enable = true; #休眠后唤醒不会花屏
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024;
  }];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
    dates = "weekly";
  };

  services.libinput.touchpad.naturalScrolling = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver.videoDrivers = [ "nvidia" ];

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
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  networking.nameservers = [ "192.168.0.99" "223.5.5.5" ];
  # networking.networkmanager.dns = "systemd-resolved";
  networking.networkmanager.insertNameservers = [ "192.168.0.99" "223.5.5.5" ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
    enable = true;
    # windowManager.qtile.enable = true;
  };
  services.displayManager.gdm.enable = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fgsd = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$OQC4oxFwRxZHzxbTGfcEs1$T/U9MAfe90lViXxkKsMonRjb3mAU8uXmS.64iTXTNh7";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "qemu" "kvm" "docker" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEfAfx9NtJjJ+5aRopDw/1WZwXPPHM8SflPIweRNPWW frsfallingsand@outlook.com"
    ];
  };

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
   };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add common libraries that foreign binaries expect
    stdenv.cc.cc
    zlib
    openssl
    libffi
    ncurses
    readline
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = false;
    xwayland.enable = true;
  };

  #programs.dotnet.dev = {
  #  enabled = true;
  #  environmentVariables = {
  #    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "0";  # Will set environment variables for DotNET.
  # };
  #};

  programs.java.enable = true;

  programs.dms-shell = {
    enable = false;

    quickshell.package = quickshellPkg;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  programs.niri = {
    enable = true;
  };
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  security.pam.services.swaylock = {};
  # programs.waybar.enable = true; # top bar


  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    git
    curl
    htop
    fastfetch
    clash-verge-rev
    pciutils
    alacritty
    fuzzel
    swaylock
    mako
    swayidle
    fish
    starship
    hyprland
    # dmsDefaultPkg
    kitty
    eza
    microsoft-edge
    gnome-extension-manager
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    lsof
    ntfs3g
    tmux
    btop
    typescript
    devbox
    lazygit
    noto-fonts
    noto-fonts-cjk-sans
    onlyoffice-desktopeditors
    appimage-run
    nerdfetch
    nerd-fonts.noto
    bibata-cursors
    tree
    starship
    helix
    cmatrix
    obsidian
    yazi
    bat
    lsd
    obs-studio
    wireguard-tools
    virt-viewer # View Virtual Machines
    lazydocker
    docker-client
    qemu_kvm # KVM support
    OVMF # UEFI firmware
    swtpm # TPM emulation
    libguestfs # VM disk tools
    virt-top # Monitor VM performance
    spice # SPICE protocol support
    spice-gtk # SPICE client GTK
    spice-protocol # SPICE protocol headers
    virglrenderer # Virtual GPU support
    mesa # OpenGL support for VMs
    ffmpeg
    qq
    wechat
    waylyrics
    protonplus
    lutris
    # umu-launcher
    wine
    imagemagick
    grim
    nvtopPackages.full
    kdePackages.kdenlive
    ncdu
    splayer
    go-musicfox
    scrcpy
    libxshmfence
    osu-lazer-bin
    jetbrains.idea
    vscode
    kotlin
    kotlin-native
    rustup
    go
    dotnet-sdk_9
    nodejs_20
    gradle_9
    maven
    easyeffects
    vlc
    krita
    timeshift
    grim
    btrfs-progs
    zram-generator
    flameshot
    fzf
    ripgrep
    fd
    zoxide
    tealdeer
    bottom
    vmware-workstation
    vmfs-tools
    # (ovftool.override { acceptBroadcomEula = true; })
    kubernetes
    kubernetes-kcp
    kubernetes-helm
    # linuxKernel.packages.linux_6_12.vmware
    telegram-desktop
    discord
    element-desktop
    texliveFull
    pandoc
    bitwarden-desktop
    protontricks
    rustdesk
    rustdesk-server
    hmcl
    pnpm
    wemeet
    linux-wallpaperengine
    # mathematica
    android-tools
    remmina
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    zenity
    nP
    affine
    kdePackages.kirigami
  ];

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common = {
      default = [
        "gtk"
      ];
    };
    # 移除 gtk/kde 后端避免冲突
  };

  programs.virt-manager.enable = true;
  programs.dconf.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.enableVirtualCamera = true;

  virtualisation = {
    docker = {
      enable = true;
    };

    podman.enable = false;

    libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
      qemu = {
        runAsRoot = false;
        # ovmf submodule REMOVED: All OVMF images are now available by default in nixpkgs-unstable
        swtpm.enable = true; # TPM emulation
        vhostUserPackages = with pkgs; [ virtiofsd ];

        verbatimConfig = ''
          user = "qemu-libvirtd"
          group = "kvm"
          dynamic_ownership = 1
          remember_owner = 0
        '';
      };
      allowedBridges = [
        "virbr0" # Default NAT bridge
        "br0" # Custom bridge if needed
      ];
    };

    # Kernel modules for better VM performance
    spiceUSBRedirection.enable = true;
  };


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
    ];
    # From End4's hyprland dotfiles
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "kde";
    XDG_MENU_PREFIX = "plasma-";
    TERMINAL = "kitty -1";
  };

  fonts = {
    fontDir.enable = true; # 启用旧版字体路径兼容
    packages = with pkgs; [
      cascadia-code
      noto-fonts 
      noto-fonts-cjk-sans    # 思源黑体
      noto-fonts-cjk-serif   # 思源宋体
      noto-fonts-color-emoji
      source-han-sans        # 思源黑体
      nerd-fonts.noto
      nerd-fonts.jetbrains-mono
    ];
    
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK SC" "DejaVu Sans" ];
        serif = [ "Noto Serif CJK SC" "DejaVu Serif" ];
        monospace = [ "Cascadia Code" "Noto Sans Mono CJK SC" ];
      };
    };
  };


  services.flatpak.enable = true;

  # GNOME Software 配置（备用）
  # environment.systemPackages = with pkgs; [
  #   gnome-software
  # ];

  # 国内 Flatpak 镜像源配置
  systemd.services.configure-flatpak-repo = {
    description = "Configure Flatpak Domestic Mirrors";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      # === 选项 A: 上海交通大学 (SJTU) - 推荐 ===
      flatpak remote-add --if-not-exists flathub https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
      flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub/

      # === 选项 B: 中国科学技术大学 (USTC) - 备用 ===
      # flatpak remote-add --if-not-exists flathub https://mirrors.ustc.edu.cn/flathub/flathub.flatpakrepo
      # flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub/

      # 强制刷新元数据，确保 GNOME Software 搜索结果及时更新
      flatpak update --appstream
    '';
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

