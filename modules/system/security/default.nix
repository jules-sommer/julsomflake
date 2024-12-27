{ ... }:
{

  security = {
    polkit = {
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
