{lib, ...}: let
  inherit (lib) enabled';
in {
  home.services.kanshi = enabled' {
    settings = [
      {
        profile = {
          name = "jules-sunnymeade-dual";
          outputs = [
            {
              criteria = "HDMI-A-1";
              position = "0,0";
            }
            {
              criteria = "DP-1";
              position = "1920,0";
              mode = "2560x1080@74.990997Hz";
            }
          ];
        };
      }
    ];
  };
}
