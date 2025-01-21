{
  lib,
  eachSystem,
  self,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    filterAttrs
    hasAttr
    ;
in
rec {
  # Returns a filtered attrset of users that are "normal users", i.e have key `isNormalUser = true;`
  # all-users argument is the value of `config.users.users`
  getNormalUsers = users: filterAttrs (_: userAttrs: userAttrs.isNormalUser or false) users;

  getUserHomeDir = user: user.home or "/home/${user.name}";

  getUserHomeDirFromStr =
    users: user: if hasAttr user users then users.${user}.home else "/home/${user}";

  getAllUserHomeDirs = users: lib.mapAttrs (_: getUserHomeDir) users;

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  enabled' =
    cfg:
    {
      enable = true;
    }
    // cfg;

  disabled' =
    cfg:
    {
      enable = false;
    }
    // cfg;

  makeChannel = system: input: {
    inherit system;
    inherit (input) lib;
    inherit (input.lib) version;
    _input = input;
    pkgs = input.legacyPackages.${system};
  };

  extendLib =
    nixpkgs: extension:
    nixpkgs.lib.extend (
      _: prev:
      {
        __extended = true;
      }
      // prev
      // extension
    );

  mkEnableOpt = description: { enable = lib.mkEnableOption description; };

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;

  ## Create a boolean NixOS module option.
  ##
  ## ```nix
  ## lib.mkBoolOpt true "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt = mkOpt types.bool;

  ## Create a NixOS module option, with an optional description.
  ##
  ## Usage without description:
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default"
  ## ```
  ##
  ## Usage with description:
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> Optional String -> mkOption
  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  ## Create a boolean NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;
}
