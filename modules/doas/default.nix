{
  helpers,
  pkgs,
  config,
  ...
}: let
  inherit (helpers) enabled' modules;
  inherit (modules) disabledIf;
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
}
