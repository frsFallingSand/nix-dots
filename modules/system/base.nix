{
  config,
  lib,
  pkgs,
  cachy,
  ...
}:

# Core boot, kernel, Nix, and low-level system defaults.

{
  nixpkgs.config.problems.handlers = {
    libguestfs.broken = "warn";
  };

  # VMware's external modules used to be copied by hand, so recent
  # nixpkgs aggregateModules could not find vmmon.ko.cer/vmnet.ko.cer.
  # Build and install them through Kbuild, which also produces the
  # certificate files expected by the module aggregator.
  nixpkgs.overlays = [
    (final: prev: {
      kernelPackagesExtensions = prev.kernelPackagesExtensions ++ [
        (finalKernelPackages: prevKernelPackages: {
          vmware =
            let
              kernel = finalKernelPackages.kernel;
              moduleMakeFlags = finalKernelPackages.kernelModuleMakeFlags;
            in
            prevKernelPackages.vmware.overrideAttrs (old: {
              makeFlags = (old.makeFlags or [ ]) ++ moduleMakeFlags;
              installPhase = ''
                runHook preInstall

                for module in vmmon vmnet; do
                  make ${lib.escapeShellArgs moduleMakeFlags} \
                    -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
                    M="$PWD/$module-only" \
                    INSTALL_MOD_PATH="$out" \
                    INSTALL_MOD_DIR=misc \
                    DEPMOD=true \
                    modules_install
                done

                runHook postInstall
              '';
            });
        })
      ];
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    # "electron-39.8.10"
    # "pnpm-9.15.9"
    # "pnpm-10.29.2"
  ];

  systemd.services.libvirtd.serviceConfig = {
    LoadCredentialEncrypted = lib.mkForce [ ];
    LoadCredential = lib.mkForce [ ];
    ImportCredential = lib.mkForce [ ];
  };

  systemd.services.virt-secret-init-encryption.enable = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
  ];
  boot.kernelModules = [
    "fuse"
    "kvm-amd"
    "kvm-intel"
    "vfio-pci"
    "tun"
    "nft_compat"
    "nf_tables"
  ];

  boot.tmp.useTmpfs = true;

  boot.kernel.sysctl."kernel.sysrq" = 1;

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  # boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;
  boot.kernelPackages = pkgs.linuxPackagesFor cachy;

  # boot.zfs.package = pkgs.zfs_cachyos;

  virtualisation.vmware.host.enable = false;
  virtualisation.vmware.host.extraPackages = with pkgs; [
    libaio
    pcsclite
    # linuxKernel.packages.linux_zen.vmware
  ];
  virtualisation.vmware.guest.enable = true;

  services.logind.settings.Login.HandlePowerKey = "ignore";

  hardware.uinput.enable = true;

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    # "loglevel=7"
  ];
  boot.consoleLogLevel = 7;

  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/isos 0755 qemu-libvirtd kvm -"
    "d /var/lib/libvirt/images 0755 qemu-libvirtd kvm -"
  ];
  nix.gc = {
    automatic = false;
    options = "--delete-older-than 14d";
    dates = "weekly";
  };

  services.libinput.touchpad.naturalScrolling = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.substituters = [ "https://cache.lantian.pub/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];

}
