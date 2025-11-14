{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    types
    attrsets
    optionalAttrs
    foldl'
    enabled
    mkEnableOpt
    mkOpt
    enabled'
    getModulesRecursive
    mkOption
    ;
  inherit (attrsets) recursiveUpdate;
  inherit (types) nullOr enum;
  cfg = config.local.wayland;

  dbg-wayland-env = pkgs.callPackage ./__debug-env.nix {};

  mkSessionCommand = compositor:
    pkgs.writeShellScriptBin "wayland-session-${compositor}" ''
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=${compositor}

      exec ${compositor}
    '';

  defaultSession =
    if cfg.activeCompositor == "niri"
    then mkSessionCommand "niri"
    else if cfg.activeCompositor == "river"
    then mkSessionCommand "river"
    else if cfg.activeCompositor == "plasma"
    then "startplasma-wayland"
    else if cfg.activeCompositor == "hyprland"
    then "hyprland"
    else builtins.warn "No active wayland compositor is set, assuming default." "niri";

  defaultSessionBin = "${defaultSession}/bin/wayland-session-${cfg.activeCompositor}";
in {
  imports = getModulesRecursive ./. {
    max-depth = 1;
    blacklist = [
      {
        # exclude evremap/keys.nix since it is itself not a nixos module
        name = "keys.nix";
        kind = "regular";
        depth = 1;
      }
    ];
  };

  options.local.wayland = {
    enable =
      mkOpt types.bool false
      "Enable wayland support, setting this option to true configures and enables wayland-related portals and other settings. And disables xserver if not already.";

    activeCompositor = mkOption {
      type = nullOr (enum ["niri" "river" "plasma" "hyprland"]);
      default = "niri";
      description = "Which Wayland compositor is currently active";
    };

    login = {
      greetd = mkEnableOpt "Enable greetd login manager.";
    };
  };

  config = foldl' recursiveUpdate {} [
    {
      services.playerctld = enabled;

      # TODO: maybe go through these and figure out what's actually needed?
      environment.systemPackages = with pkgs; [
        slurp
        grim
        mpv
        wev
        wshowkeys
        cliphist
        wlrctl
        waylock
        wbg
        brightnessctl
        playerctl
        imv
      ];
    }
    {
      # security.pam.services.greetd.enableGnomeKeyring = true;
      services.greetd = {
        inherit (cfg.login.greetd) enable;
        settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${defaultSessionBin}";
      };
    }
    {
      services.xserver = {
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
    }
  ];
}
