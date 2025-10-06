{lib}: let
  inherit
    (lib)
    types
    mkOption
    filterAttrs
    toString
    isString
    hasAttr
    ;
in rec {
  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  enabled' = cfg:
    {
      enable = true;
    }
    // cfg;

  disabled' = cfg:
    {
      enable = false;
    }
    // cfg;

  mkEnableOpt = description: {enable = lib.mkEnableOption description;};

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;
  mkOptNoDesc = mkOpt';

  mkOptWithExample = type: default: example: description:
    mkOption {
      inherit
        type
        default
        description
        example
        ;
    };

  # this is the same as `mkOptWithExample` but instead accepts a string
  # for the example, or if not provided a string, will try to perform `toString`
  # on the provided example value.
  mkOptWithExampleString = type: default: example': description: let
    example =
      if isString example
      then example
      else toString example;
  in
    mkOption {
      inherit
        type
        default
        description
        example
        ;
    };

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
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  ## Create a boolean NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;
}
