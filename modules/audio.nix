{
  config,
  lib,
  helpers,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
  inherit
    (helpers)
    enabled
    enabled'
    modules
    mkEnableOpt
    enabledPred
    disabled
    ;

  inherit (modules) mergeAttrs includeIf;
  cfg = config.local.audio;

  extraLv2Packages = with pkgs; [
    lsp-plugins
  ];
in {
  options.local.audio = {
    pipewire =
      mkEnableOpt "Enable pipewire audio support."
      // {
        settings = {
          compatibility = mkEnableOption "Enable backwards compatbility with jack, alsa, and pulse audio services via emulation.";
          withExtras = mkEnableOption "Enable extra software for configuring and managing pipewire audio on your system, such as helvum, pwvucontrol, etc.";
        };
      };
  };

  config = mergeAttrs [
    (includeIf (cfg.pipewire.enable && cfg.pipewire.settings.withExtras) {
      environment.systemPackages = with pkgs; [
        friture
        sonic-visualiser
        pavucontrol
        pwvucontrol
        helvum
        coppwr
      ];
    })
    (includeIf cfg.pipewire.enable {
      security.rtkit.enable = true;
      services = {
        pulseaudio = disabled;
        pipewire = enabled' {
          inherit extraLv2Packages;
          wireplumber = enabled' {
            inherit extraLv2Packages;
          };
        };
      };
    })
    (includeIf cfg.pipewire.settings.compatibility {
      services.pipewire = {
        alsa = enabled' {
          support32Bit = true;
        };
        pulse = enabled;
        jack = enabled;
      };
    })
  ];
}
