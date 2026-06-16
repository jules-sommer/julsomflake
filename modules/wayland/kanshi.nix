{lib, ...}: let
  inherit (lib) enabled';
in {
  local.home.services.kanshi = enabled' {
    settings = [
      {
        profile = {
          name = "jules-sunnymeade-triple";
          outputs = [
            {
              # PNP(XEC) ES-27X3 [HDMI-A-1]
              criteria = "HDMI-A-1";
              mode = "1920x1080@100Hz";
              transform = "270";
              position = "840,0";
            }
            {
              # LG Electronics LG HDR WFHD [DP-1]
              criteria = "DP-1";
              position = "4480,652";
              mode = "2560x1080@74.990997Hz";
            }
            {
              # Sceptre Tech Inc C305W-2560UN [DP-2]
              criteria = "DP-2";
              position = "1920,652";
              mode = "2560x1080@85.001Hz";
            }
          ];
        };
      }
    ];
  };
}
