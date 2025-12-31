{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkOpt enabled mkIf mkMerge enabled';
  cfg = config.local.communication;
in {
  options.local.communication = {
    discord = mkOpt lib.types.bool true "Enable Discord (via Vesktop client).";
    signal = mkOpt lib.types.bool true "Enable Signal, secure encrypted messaging, desktop client.";
    zapzap = mkOpt lib.types.bool true "Enable ZapZap, a native Qt Whatsapp desktop client.";
  };

  config = mkMerge [
    (mkIf cfg.signal {
      environment.systemPackages = with pkgs; [signal-desktop];
    })
    (mkIf cfg.discord {
      local.home.home.packages = with pkgs; [legcord];
      local.home.programs.vesktop = enabled' {
        package = pkgs.vesktop;
      };
    })
    (mkIf cfg.zapzap {
      local.home.programs.zapzap = enabled' {
        settings.system = {
          scale = 150;
          theme = "dark";
          wayland = true;
        };
      };
    })
  ];
}
