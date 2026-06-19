{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    getExe'
    mkEnableOpt
    mkEnableOption
    getModulesRecursive
    ;
  cfg = config.local.wayland;
in {
  imports = getModulesRecursive ./. {max-depth = 1;};

  options.local.wayland = {
    enable = mkEnableOption "wayland utilities and config module";
    login.greetd = mkEnableOpt "Enable greetd login manager.";
  };

  config = {
    programs.kde-pim = {inherit (cfg) enable;};

    local.home.home.activation.rebuildKdeCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental
    '';

    # TODO: maybe go through these and figure out what's actually needed?
    environment.systemPackages = with pkgs; [
      slurp
      grim
      mpv
      wev
      wshowkeys
      wlrctl
      brightnessctl
      playerctl
    ];

    security.pam.services.greetd = {
      enableGnomeKeyring = true;
      kwallet = {
        inherit (cfg) enable;
        package = pkgs.kdePackages.kwallet-pam;
      };
    };

    services = {
      greetd = {inherit (cfg.login.greetd) enable;};
      playerctld.enable = true;
      udisks2.enable = true;
      upower.enable = config.powerManagement.enable;
      libinput.enable = true;
      geoclue2.enable = true;
      fwupd.enable = true;

      xserver = {
        enable = !cfg.enable;
        videoDrivers = ["amdgpu"];
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
        autorun = true;
        xkb = {
          layout = "us";
          options = "compose:ralt";
        };
      };
    };
  };
}
