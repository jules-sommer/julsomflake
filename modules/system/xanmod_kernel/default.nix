{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  kernelModules = pkgs.linuxKernel.packages.linux_xanmod_latest;
  cfg = config.local.kernel.xanmod;
in
{
  options.local.kernel.xanmod = {
    enable = mkEnableOption "Enable xanmod kernel configuration module.";
    zfs = {
      enable = mkEnableOption "Enable ZFS kernel modules.";
    };
  };

  config = {
    boot =
      (mkIf cfg.zfs.enable {
        supportedFilesystems = [ "zfs" ];
        zfs.forceImportRoot = false;
      })
      // {

        kernelPackages = pkgs.linuxPackages_xanmod_latest;
        kernelModules = with kernelModules; [
          v4l2loopback
          zfs_unstable
          virtio_vmmci
          virtualbox
          virtualboxGuestAdditions
          zenergy
          zenpower
          ryzen-smu
          rr-zen_workaround
        ];

        kernel = {
          enable = true;
          sysctl = {
            "vm.max_map_count" = 2147483642; # Needed For Some Steam Games
            "kernel.perf_event_paranoid" = -1; # needed for tracing/debugging programs like rr
            "kernel.kptr_restrict" = lib.mkForce 0; # transparent ptr addresses for kernel memory
          };
        };
      };
  };
}
