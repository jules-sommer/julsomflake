{
  helpers,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (helpers) enabled' modules;
  inherit (modules) disabledIf;
  inherit (lib) mkIf;

  cfg = config.security.doas;
in {
  security = {
    polkit = enabled' {
      adminIdentities = [
        "unix-user:jules"
        "unix-group:wheel"
      ];
    };

    sudo = disabledIf config.security.doas.enable;
    doas = enabled' {
      extraRules = [
        {
          cmd = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          args = [];
          noPass = true;
          keepEnv = true;
          groups = ["wheel"];
        }
        {
          groups = ["wheel"];
          persist = true;
          keepEnv = true;
        }
      ];
    };
  };

  local.shells.settings.aliases = mkIf cfg.enable {
    sudo = "doas";
    sudoedit = "doas rnano";
  };
}
