{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) getExe;
  rsync = getExe pkgs.rsync;
  simple-mtpfs = getExe pkgs.simple-mtpfs;
in {
  environment.systemPackages = [pkgs.simple-mtpfs];
  systemd = {
    tmpfiles.rules = [
      "d /mnt/phone 0755 jules users -"
    ];
    services.phone-backup = {
      description = "Mount phone and sync to staging directory";
      serviceConfig = {
        Type = "oneshot";
        User = "jules";
        ExecStart = pkgs.writeShellScript "phone-backup" ''
          ${simple-mtpfs} /mnt/phone
          ${rsync} -av --delete --dry-run --log-file=/home/jules/phone-backup.log /mnt/phone/ /mnt/BACKUPS/jules-S26
          fusermount -u /mnt/phone
        '';
      };
    };
  };
}
