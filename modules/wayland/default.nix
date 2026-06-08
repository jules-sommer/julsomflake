{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) writeShellScriptBin;
  inherit
    (lib)
    mkIf
    types
    attrsets
    foldl'
    enabled
    getExe
    getExe'
    mkEnableOpt
    mkOpt
    getModulesRecursive
    mkOption
    ;
  inherit (attrsets) recursiveUpdate;
  inherit (types) nullOr enum;
  cfg = config.local.wayland;

  mkSessionCommand = compositor:
    getExe (writeShellScriptBin "wayland-session-${compositor}" ''
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=${compositor}

      exec ${compositor}
    '');

  niriSession = writeShellScriptBin "wayland-session-niri" ''
    export XDG_SESSION_TYPE=wayland
    ${getExe pkgs.niri} --session
  '';

  defaultSession =
    if cfg.activeCompositor == "niri"
    then getExe' pkgs.niri "niri-session"
    else if cfg.activeCompositor == "river"
    then mkSessionCommand "river"
    else if cfg.activeCompositor == "plasma"
    then getExe' pkgs.kdePackages.plasma-workspace "startplasma-wayland"
    else niriSession;
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
      {
        name = "eww";
        kind = "directory";
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
      local.home.home.activation.rebuildKdeCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
      '';
    }
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
      security.pam.services.greetd.enableGnomeKeyring = true;
      services.greetd = {
        inherit (cfg.login.greetd) enable;
        settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${defaultSession}";
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
