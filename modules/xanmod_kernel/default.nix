{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkEnableOpt enabled' recursiveUpdate foldl';
  kernelModules = pkgs.linuxKernel.packages.linux_xanmod_latest;
  cfg = config.local.kernel.xanmod;
in {
  options.local.kernel.xanmod = {
    enable = mkEnableOption "Enable xanmod kernel configuration module.";
    zfs = mkEnableOpt "Enable ZFS kernel modules.";
    btrfs = mkEnableOpt "Enable btrfs kernel modules.";
  };

  config = {
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

    boot = foldl' recursiveUpdate {} [
      (mkIf cfg.zfs.enable {
        supportedFilesystems = ["zfs"];
        zfs.forceImportRoot = false;
        kernelModules = with kernelModules; [
          zfs_unstable
        ];
      })
      (mkIf cfg.btrfs.enable {
        supportedFilesystems = ["btrfs"];
      })
      {
        kernelModules = with kernelModules; [
          v4l2loopback
          virtio_vmmci
          virtualbox
          virtualboxGuestAdditions
          zenergy
          zenpower
          ryzen-smu
          rr-zen_workaround
        ];
      }
      {
        plymouth.enable = true;
        kernelPackages = pkgs.linuxPackages_xanmod_latest;

        kernel = enabled' {
          sysctl = {
            "vm.max_map_count" = 2147483642; # Needed For Some Steam Games
            "kernel.perf_event_paranoid" = -1; # needed for tracing/debugging programs like rr
            "kernel.kptr_restrict" = lib.mkForce 0; # transparent ptr addresses for kernel memory
          };
        };
      }
    ];
  };
}
