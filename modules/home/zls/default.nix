{ pkgs, lib, ... }:
let
  inherit (lib)
    elem
    elemAt
    attrNames
    filter
    ;
  inherit (builtins) readDir;
in
{
  home.packages = with pkgs; [ zls ];
  xdg.configFile = {
    "zls.json" = {
      enable = true;
      target = "zls.json";
      text =
        let
          buildRunnerDir = "${pkgs.zls.src}/src/build_runner/";
          buildRunnerDirContents = readDir buildRunnerDir;
          # Filters out the known files which are not the build runner but related code not relevant to us here.
          filteredBuildRunnerDirContents = filter (
            filename:
            !elem filename [
              "BuildRunnerVersion.zig"
              "shared.zig"
            ]
          ) (attrNames buildRunnerDirContents);
        in
        # buildRunnerDirListing = builtins.readDir "${pkgs.zls.src}/src/build_runner/${pkgs.zls.version}.zig";
        # simpleVersionPath = "${pkgs.zls.src}/src/build_runner/${pkgs.zls.version}.zig";
        # computedPath = if builtins.pathExists simpleVersionPath then simpleVersionPath else ;
        builtins.toJSON {
          build_runner_path = "${pkgs.zls.src}/src/build_runner/${elemAt filteredBuildRunnerDirContents 0}";
        };
    };
  };
}
