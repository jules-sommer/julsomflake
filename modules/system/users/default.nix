{ pkgs, lib, ... }:
{
  config = {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "no";
        PrintLastLog = "no";
        PasswordAuthentication = false;
        UsePAM = false;
        X11Forwarding = false;
      };
    };

    programs.zsh.enable = true;

    users = {
      # defaultUserShell = pkgs.fish;
      users = {
        bun = {
          isNormalUser = true;
          initialPassword = "bun";
          useDefaultShell = true;
          createHome = true;

          shell = pkgs.zsh;

          extraGroups = [
            "users"
            "rtkit"
            "networkmanager"
          ];
        };
        jules = {
          isNormalUser = true;
          initialHashedPassword = "$y$j9T$UjcDzGjlMaK0Eq2dTB02m1$WQG.JC7aZXlDhKxx2hkHa7f.vDw8TY2GQSmCuBPne58";
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
  };
}
