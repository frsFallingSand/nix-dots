# Compatibility entry point for the former combined Home Manager module.
{ ... }:
{
  imports = [
    ./desktop.nix
    ./packages.nix
  ];
}
