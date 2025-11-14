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
      wheelNeedsPassword = false;
      extraRules = [
        {
          cmd = "/run/current-system/sw/bin/nixos-rebuild";
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
