{
  lib,
  config,
  pkgs,
  helpers,
  ...
}: let
  inherit
    (helpers)
    enabled'
    enabled
    enabledPred
    mkEnableOpt
    ;
  inherit
    (lib)
    isString
    isList
    isDerivation
    isPath
    escapeShellArg
    escapeShellArgs
    mapAttrsToList
    concatStringsSep
    optionalString
    typeOf
    foldl'
    foldr
    head
    zipAttrsWith
    ;

  cfg = config.local.wayland.river;

  inherit (lib.attrsets) recursiveUpdate;

  mergeWithFn = sets: fn:
    foldr (
      x: y:
        zipAttrsWith fn [
          x
          y
        ]
    ) {}
    sets;

  mergePriority = sets: mergeWithFn sets (_: head);
  getExecutable = drv: let
    name =
      if lib.hasAttr "pname" drv
      then drv.pname
      else if lib.hasAttr "name" drv
      then drv.name
      else if lib.hasAttr "meta" drv && lib.hasAttr "name" drv.meta
      then drv.meta.name
      else throw "Can't determine binary name for package: ${drv}";
  in "${lib.getBin drv}/bin/${name}";

  getBinaryByName = drv: name: "${lib.getExe drv}/bin/${name}";

  traceSpawn = args: let
    s = spawn args;
  in
    builtins.trace s s;

  spawn = command: let
    resolveProgram = prog:
      if isDerivation prog
      then getExecutable prog
      else if isPath prog
      then toString prog
      else if isString prog
      then prog
      else throw "spawn: invalid program type: ${typeOf prog}";

    buildCommand = {
      program,
      args ? [],
      env ? {},
    }: let
      cmdline = escapeShellArgs ([(resolveProgram program)] ++ args);
      envStr =
        if env == {}
        then ""
        else concatStringsSep " " (mapAttrsToList (k: v: "${k}=${escapeShellArg v}") env);
    in "spawn ${envStr}${optionalString (env != {}) " "}${cmdline}";
  in
    if isList command
    then
      buildCommand {
        program = builtins.head command;
        args = builtins.tail command;
      }
    else if isString command || isDerivation command || isPath command
    then "spawn ${escapeShellArg (resolveProgram command)}"
    else if builtins.isAttrs command
    then buildCommand command
    else throw "spawn: unsupported input type: ${typeOf command}";

  home = "/home/jules";
  wallpaperFile = "${home}/060_media/010_wallpapers/zoe-love-bg/zoe-love-4k.png";
  screenshotDir = "${home}/060_media/005_screenshots";
in {
  options.local.wayland.river = mkEnableOpt "Enable River.";
  config = {
    programs.river-classic = {
      inherit (cfg) enable;
      package = null;
      xwayland = enabled;

      # TODO: maybe go through these and figure out what's actually needed?
      extraPackages = with pkgs; [
        wayland-protocols
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        dunst
        scrot
        wlr-randr
        slurp
        grim
        mpv
        river-bnf
        river-tag-overlay
        wshowkeys
        fuzzel
        cliphist
        lswt
        wlrctl
        ydotool
        waylock
        wbg
        brightnessctl
        imv
      ];
    };

    local.home = {
      xdg.portal.xdgOpenUsePortal = true;
      wayland.windowManager.river = enabled' {
        package = pkgs.river-classic;
        systemd = enabled' {
          variables = [
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP"
            "NIXOS_OZONE_WL"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
          ];
        };
        xwayland.enable = true;
        extraSessionVariables = {
          MOZ_ENABLE_WAYLAND = "1";
        };
        settings = {
          declare-mode = [
            "locked"
            "normal"
            "launch"
            "resize"
            "passthrough"
          ];
          input = {
            pointer-1133-16495-Logitech_MX_Ergo = {
              pointer-accel = 0.2;
              tap = false;
              events = true;
              accel-profile = "adaptive";
            };
          };
          map = mergePriority [
            {
              normal = {
                "Super bracketright" = "focus-view next";
                "Super bracketleft" = "focus-view previous";

                "Super+Shift bracketright" = "focus-output next";
                "Super+Shift bracketleft" = "focus-output previous";

                "Super Return" = spawn {
                  program = getBinaryByName pkgs.kitty "kitty";
                };
                "Super+Shift Return" = "spawn fuzzel";
                "Super Z" = "spawn zen";

                "Super S" = traceSpawn {
                  program = "${pkgs.julespkgs.screenshot}/bin/screenshot";
                  env.SCREENSHOT_DIR = screenshotDir;
                };
                "Alt+Shift E" = traceSpawn {program = "${pkgs.emoji-picker}/emoji.sh";};

                "Super C" = "close";
                "Super+Shift E" = "exit";

                "Super N" = "focus-view next";
                "Super P" = "focus-view previous";

                "Super+Shift J" = "swap next";
                "Super+Shift K" = "swap previous";

                "Super Period" = "focus-output next";
                "Super Comma" = "focus-output previous";
                "Super H" = "focus-view left";
                "Super J" = "focus-view down";
                "Super K" = "focus-view up";
                "Super L" = "focus-view right";

                "Super+Shift Period" = "send-to-output next";
                "Super+Shift Comma" = "send-to-output previous";

                "Super Space" = "zoom";

                "Super+Shift H" = ''send-layout-cmd rivertile "main-ratio -0.05"'';
                "Super+Shift L" = ''send-layout-cmd rivertile "main-ratio +0.05"'';

                "Super+Alt H" = "move left 50";
                "Super+Alt J" = "move down 50";
                "Super+Alt K" = "move up 50";
                "Super+Alt L" = "move right 50";

                "Super+Alt+Control H" = "snap left";
                "Super+Alt+Control J" = "snap down";
                "Super+Alt+Control K" = "snap up";
                "Super+Alt+Control L" = "snap right";

                "Super+Alt+Shift H" = "resize horizontal -100";
                "Super+Alt+Shift J" = "resize vertical 100";
                "Super+Alt+Shift K" = "resize vertical -100";
                "Super+Alt+Shift L" = "resize horizontal 100";
              };
            }
            {
              launch = {
                "None Return" = "spawn kitty";
                "None Z" = "spawn zen";
                "None J" = "spawn kitty -e joshuto";
                "None Escape" = "enter-mode normal";
              };
              normal = {
                "Super+Shift L" = "enter-mode launch";
              };
            }
          ];
          rule-add = let
            genRules = key: names: value: {
              ${key} = builtins.listToAttrs (
                map (name: {
                  name = "'${name}'";
                  inherit value;
                })
                names
              );
            };
          in
            foldl' recursiveUpdate {} [
              (genRules "-app-id" ["zen" "zen-alpha" "Jan" "*"] "ssd")
            ];
          keyboard-layout = ''-options "caps:swapescape" "us"'';
          default-layout = "rivertile";
          focus-follows-cursor = "normal";
          border-width = 10;
          set-cursor-warp = "on-output-change";
          set-repeat = "50 200";
          spawn = [
            "kitty"
            "rivertile"
            "/home/jules/000_dev/010_zig/river-conf/zig-out/bin/river_conf"
            "wlr-randr --output HDMI-A-1 --pos 0,0; wlr-randr --output DP-1 --pos 1920,0 --mode 2560x1080@74.990997Hz"
            ''
              wbg "${wallpaperFile}"
            ''
            "river-bnf"
          ];
          xcursor-theme = lib.mkForce "Bibata-Modern-Ice 24";
        };
      };
    };
  };
}
