{
  lib,
  pkgs,
  config,
  src,
  ...
}: let
  inherit (lib) enabled';
in {
  services.openssh = enabled' {
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = ["jules" "forgejo"];
      PubkeyAuthentication = true;
    };
  };

  users.users.jules.openssh.authorizedKeys.keyFiles = [
  ];

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/home/jules/.ssh/id_ed25519"
    ];

    secrets.ssh-key = {
      file = lib.path.append src "secrets/id_ed25519.age";
      path = "/home/jules/.ssh/id_ed25519";
      mode = "600";
      owner = "jules";
      group = "users";
    };
  };

  environment.systemPackages = [pkgs.wayprompt];

  programs.ssh.knownHosts."*".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKa+NotW65h3HVyXzHAjrwxixpRUPi2uUmCQLMlr/98O";

  local.home = {
    services.ssh-agent.enable = true;

    systemd.user.sessionVariables = {
      SSH_ASKPASS = "${pkgs.wayprompt}/bin/wayprompt";
      SSH_ASKPASS_REQUIRE = "prefer";
    };

    programs = {
      git.extraConfig = {
        gpg.format = "ssh";
        user.signingKey = "/home/jules/.ssh/id_ed25519.pub";
        commit.gpgsign = true;
      };

      ssh = enabled' {
        addKeysToAgent = "yes";
        matchBlocks."*".identityFile = ["/home/jules/.ssh/id_ed25519"];
      };
    };
  };
}
