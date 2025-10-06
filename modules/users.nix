{
  pkgs,
  lib,
  ...
}: {
  config.users = {
    mutableUsers = true;
    defaultUserShell = pkgs.fish;
    users = {
      root = {
        isSystemUser = true;
        hashedPassword = "$y$j9T$.kN/Nal9JNqTj52joYQ6g/$aEVFLAdkc7T9rwFodCD1CN92W27G7EXEMsVIKKS2Ef5";
        useDefaultShell = true;
        createHome = false;
        shell = lib.mkForce pkgs.fish;
      };
      jules = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$.kN/Nal9JNqTj52joYQ6g/$aEVFLAdkc7T9rwFodCD1CN92W27G7EXEMsVIKKS2Ef5";
        useDefaultShell = true;
        home = "/home/jules";
        createHome = true;
        uid = 1000;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwxJcAWuHkKy/Ar37aIoqg34CDcZu7/bh978nYkOgzj"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOszCNP+6rkIS75GyFVhn9o6QpUuGdx/J4rjzROrpSl"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYusyUMuAj7kY3wis0FXQ5JzSfC6RqY/wckL+161xKn"
        ];

        extraGroups = [
          "wheel"
          "users"
          "rtkit"
          "networkmanager"
          "wireshark"
          "fuse"
        ];
      };
    };
  };
}
