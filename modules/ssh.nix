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
      PubkeyAuthentication = true;
    };
  };

  users.users.jules.openssh.authorizedKeys.keyFiles = [
  ];

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
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

  local.home = {
    services.ssh-agent.enable = true;

    systemd.user.sessionVariables = {
      SSH_ASKPASS = "${pkgs.wayprompt}/bin/wayprompt";
      SSH_ASKPASS_REQUIRE = "prefer";
    };

    programs = {
      git.extraConfig = {
        gpg.format = "ssh";
        user.signingKey = "~/.ssh/id_ed25519.pub";
        commit.gpgsign = true;
      };

      ssh = enabled' {
        addKeysToAgent = "yes";
        matchBlocks."*".identityFile = ["~/.ssh/id_ed25519"];
      };
    };
  };
}
