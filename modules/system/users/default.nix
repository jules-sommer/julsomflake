{ pkgs, ... }:
{
  config = {
    services.openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };

    users = {
      defaultUserShell = pkgs.fish;
      users = {
        jules = {
          isNormalUser = true;
          initialHashedPassword = "$y$j9T$UjcDzGjlMaK0Eq2dTB02m1$WQG.JC7aZXlDhKxx2hkHa7f.vDw8TY2GQSmCuBPne58";
          useDefaultShell = true;
          home = "/home/jules";
          homeMode = "700";
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
  };
}
