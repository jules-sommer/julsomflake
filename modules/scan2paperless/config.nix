{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optional optionals;

  cfg = config.services.scan2paperless;

  post2paperless = pkgs.writeShellApplication {
    name = "post2paperless";
    runtimeInputs = [pkgs.curl pkgs.jq];
    text =
      ''
        hostname="${cfg.host}"
        user="${cfg.user}"
        rawpw=$(cat ${lib.escapeShellArg cfg.passwordFile})
        creds="$(printf '%s' "$user:$rawpw" | base64)"
      ''
      + builtins.readFile ./post2paperless.sh;
  };

  scan2paperless = pkgs.writeShellApplication {
    name = "scan2paperless";
    runtimeInputs = [pkgs.sane-airscan pkgs.imagemagick pkgs.img2pdf pkgs.bc post2paperless];
    text =
      ''
        device=${lib.escapeShellArg cfg.device}
      ''
      + builtins.readFile ./scan2paperless.sh;
  };
in {
  config = {
    hardware.sane = {
      extraBackends = optional cfg.enable pkgs.sane-airscan;
    };
    environment.systemPackages = optionals cfg.enable [scan2paperless post2paperless];
  };
}
