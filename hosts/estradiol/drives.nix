{config, ...}: {
  boot.kernelModules = ["ntfs3"];
  fileSystems = let
    uid = config.users.users.jules.uid |> toString;
    gid = config.users.groups.${config.users.users.jules.group}.gid |> toString;
  in {
    "/mnt/000_kingston_500G" = {
      device = "/dev/disk/by-uuid/08BE7A82BE7A6858";
      fsType = "ntfs3";
      options = ["uid=${uid}" "gid=${gid}" "dmask=022" "fmask=133" "noatime" "nofail" "x-systemd.automount"];
    };
    "/mnt/010_wdc_1000G" = {
      device = "/dev/disk/by-uuid/82466B90466B83AF";
      fsType = "ntfs3";
      options = ["uid=${uid}" "gid=${gid}" "dmask=022" "fmask=133" "noatime" "nofail" "x-systemd.automount"];
    };
  };
}
