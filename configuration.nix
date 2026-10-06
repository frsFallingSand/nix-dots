{ ...
}:

{
  imports = [
    ./hardware-configuration.nix
    # System modules are split by responsibility so hardware, desktop, services,
    # and package choices can be changed independently.
    ./modules/system/base.nix
    ./modules/system/hardware.nix
    ./modules/system/network.nix
    ./modules/system/desktop.nix
    ./modules/system/users.nix
    ./modules/system/programs.nix
    ./modules/system/packages.nix
    ./modules/system/services.nix
    ./modules/system/virtualization.nix
    ./modules/system/flatpak.nix
  ];

  # Keep this value stable unless the on-disk state format is deliberately
  # migrated. It does not select the nixpkgs release.
  system.stateVersion = "25.11";
}
