{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  security = {
    polkit = lib.mkDefault {
      enable = true;
      adminIdentities = [
        "unix-user:jules"
        "unix-group:wheel"
      ];
    };

    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          persist = true;
          keepEnv = true;
        }
      ];
    };
  };
}
