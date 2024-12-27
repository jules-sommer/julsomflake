{
  lib,
  config,
  inputs,
  ...
}:
{
  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  environment.etc = lib.mapAttrs' (name: value: {
    name = "/home/jules/.nix-defexpr/channels_root/nixos/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );
  };
}
