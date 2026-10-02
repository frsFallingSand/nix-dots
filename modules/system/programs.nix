{ pkgs
, quickshellPkg
, ...
}:

# System programs and desktop services.

{
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
    alsa-lib

    # 图形与多媒体基础库 (Electron 应用需要)
    libGL
    libGLU
    libglvnd
    libX11
    libXext
    libXrender
    libXtst
    libXi
    libXcomposite
    libXdamage
    libXfixes
    libXrandr
    libxcb

    # NVIDIA CUDA 相关库 (如果你要开启 GPU Offload，必选)
    linuxPackages.nvidia_x11
    cudaPackages.cudatoolkit
    cudaPackages.cuda_nvrtc
    cudaPackages.libcublas

    vulkan-loader
    libva-vdpau-driver
    libvdpau-va-gl

    glib

    # Fuck MCEF
    nspr
    nss
  ];

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

}
