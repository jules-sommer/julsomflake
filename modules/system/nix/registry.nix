{
  lib,
  config,
  inputs,
  ...
}:
{
  environment.etc = lib.mapAttrs' (name: value: {
    name = "/home/jules/.nix-defexpr/channels_root/nixos/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix = {
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };
}
