{lib, ...}: let
  inherit (lib) enabled' enabled;
in {
  local.home.programs.niri.settings.input = {
    warp-mouse-to-focus = enabled;
    focus-follows-mouse = enabled' {
      max-scroll-amount = "5%";
    };

    mod-key = "Super";
    mod-key-nested = "Alt";
    mouse = {
      natural-scroll = true;
      accel-speed = 0.22;
      accel-profile = "adaptive";
      scroll-factor = 1.5;
      scroll-method = "on-button-down";
      scroll-button = 274;
    };
    keyboard = {
      xkb = {
        layout = "us";
        options = "compose:ralt";
      };
      repeat-delay = 200;
      repeat-rate = 50;
    };
  };
}
