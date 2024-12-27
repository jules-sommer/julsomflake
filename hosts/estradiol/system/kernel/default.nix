{ pkgs, lib, ... }:
{
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.ffmpeg
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "L /lib - - - - /run/current/system/lib"
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelParams = [ ];
    kernel = {
      enable = true;
      sysctl = {
        "vm.max_map_count" = 2147483642; # Needed For Some Steam Games
        "kernel.perf_event_paranoid" = -1; # needed for tracing/debugging programs like rr
        "kernel.kptr_restrict" = lib.mkForce 0; # transparent ptr addresses for kernel memory
      };
    };

    plymouth.enable = true;
  };
}
