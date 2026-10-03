{
  pkgs,
  nP,
  lutr,
  drawingTabletPkg,
  ...
}:

# System package profile.

{
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).

  environment.systemPackages =
    with pkgs;
    [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
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
      hyprland-qtutils
      hyprland-protocols
      hyprland-workspaces
      hyprland-activewindow
      hyprland-qt-support
      hyprland-workspaces-tui
      xwayland-satellite
      # dmsDefaultPkg
      kitty
      eza
      microsoft-edge
      gnome-extension-manager
      gst_all_1.gstreamer
      # Install coreelements alongside the CLI tools (the default bin output).
      gst_all_1.gstreamer.out
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
      helix
      cmatrix
      obsidian
      yazi
      bat
      lsd
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
      # lutris
      umu-launcher
      wine
      imagemagick
      grim
      nvtopPackages.full
      kdePackages.kdenlive
      ncdu
      splayer-next
      go-musicfox
      scrcpy
      libxshmfence
      osu-lazer-bin
      jetbrains.idea
      vscode
      kotlin
      kotlin-native
      kotlin-language-server
      jdt-language-server
      rustup
      cargo
      go
      dotnet-sdk_9
      nodejs_22
      gradle_9
      maven
      easyeffects
      vlc
      krita
      timeshift
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
      # vmfs-tools
      # (ovftool.override { acceptBroadcomEula = true; })
      kubernetes
      kubernetes-kcp
      kubernetes-helm
      # linuxKernel.packages.linux_6_12.vmware
      telegram-desktop
      discord
      element-desktop
      texliveFull
      texlivePackages.ctex
      pandoc
      # bitwarden-desktop
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
      # javaPackages.compiler.openjdk17
      unzip
      python3
      clang
      clang-tools
      prettier
      lua
      lua-language-server
      gopls
      ruff
      yt-dlp
      gimp
      prismlauncher
      nss
      flite
      gnumake
      nixd
      nixdoc
      nspr
      cups
      maa-cli
      lmstudio
      aria2
      # nodePackages.yun-playlist-downloader
      # nodePackages.openclaw
      openssl
      nixpkgs-fmt
      nixpkgs-vet
      nixpkgs-lint
      nixpkgs-track
      winetricks
      cloudflare-warp
      cloudflared
      gcc-arm-embedded-13
      bear
      gcc
      zim
      zim-tools
      kiwix
      kiwix-tools
      shutter
      cups-pdf-to-pdf
      neovim
      material-symbols
      helm
      netcap
      authenticator
      hyprlock
      gitlab-kas
      gitlab-runner
      gcli
      glab
      rmpc
      crosspipe
      mpd
      pkg-config-unwrapped
      glib
      glibc
      pipewire
      opencode
      virtio-win
      blender
      blendfarm
      intel-gpu-tools
      looking-glass-client
      OVMFFull
      scream
      just
      nvd
      # flclash
      # hyprlandPlugins.hyprsplit
      wev
      opentabletdriver
      hashdeep
      rhash
      p7zip
      peazip
      p7zip-rar
      unrar
      typescript-language-server
      wayvnc
      rustc
      sunshine
      moonlight-qt
      webrtc-audio-processing
      dnsutils
      guestfs-tools
      bpftools
      iputils
      claude-code
      reptyr
      psmisc
      codex
      drawingTabletPkg
      gamescope
      mangohud
      tcpdump
      lftp
      (
        let
          base = pkgs.appimageTools.defaultFhsEnvArgs;
        in
        pkgs.buildFHSEnv (
          base
          // {
            name = "fhs";
            targetPkgs =
              pkgs:
              # pkgs.buildFHSEnv provides only a minimal FHS environment,
              # lacking many basic packages needed by most software.
              # Therefore, we need to add them manually.
              #
              # pkgs.appimageTools provides basic packages required by most software.
              (base.targetPkgs pkgs)
              ++ (with pkgs; [
                pkg-config
                ncurses
                zenity
                # Feel free to add more packages here if needed.
              ]);
            profile = "export FHS=1";
            runScript = "bash";
            extraOutputsToInstall = [ "dev" ];
          }
        )
      )
    ]
    # ++ [ nvim ];
    ++ [ lutr ];

}
