{
  config,
  lib,
  helpers,
  wallpapers,
  ...
}: let
  inherit (lib) genAttrs flatten filter unique;
  inherit (helpers) mkEnableOpt;
  cfg = config.local.wayland.wpaperd;

  kanshiOutputs =
    config.home.services.kanshi.settings
    |> map (s: s.profile.outputs)
    |> flatten
    |> filter (o: o.criteria != null)
    |> map (o: o.criteria)
    |> unique;
in {
  options.local.wayland.wpaperd = mkEnableOpt "wpaperd wallpaper daemon";
  config.local.home.services.wpaperd = {
    inherit (cfg) enable;
    settings = lib.mkDefault {
      any = {
        path = wallpapers.dir;
        duration = "30m";
        sorting = "ascending";
      };
    };
    # settings = genAttrs kanshiOutputs (_: {
    #   path = wallpapers.dir;
    #   duration = "1h";
    #   sorting = "random";
    # });
  };
}
