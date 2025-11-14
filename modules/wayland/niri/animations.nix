{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkIf
    enabled'
    genAttrs
    foldl'
    recursiveUpdate
    ;

  cfg = config.local.wayland;
  isNiriActiveCompositor = cfg.activeCompositor == "niri";
in {
  config.local.home.programs.niri.settings.animations = foldl' recursiveUpdate {} [
    (genAttrs
      [
        "window-open"
        "window-close"
        "overview-open-close"
        "config-notification-open-close"
      ]
      (_:
        enabled' {
          kind = {
            easing = {
              curve = "cubic-bezier";
              curve-args = [1.0 0.42 0.09 0.89];
              duration-ms = 150;
            };
          };
        }))

    (genAttrs
      [
        "horizontal-view-movement"
        "window-movement"
        "window-resize"
        "workspace-switch"
        "screenshot-ui-open"
        "exit-confirmation-open-close"
      ]
      (_:
        enabled' {
          kind.spring = {
            damping-ratio = 0.75;
            stiffness = 430;
            epsilon = 0.0001;
          };
        }))
  ];
}
