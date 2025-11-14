{
  lib,
  pkgs,
  config,
  src,
  ...
}: let
  inherit (lib) enabled' getBinary;
in {
  services = {
    openssh = enabled' {
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
      };
    };
    gnome = {
      gnome-keyring.enable = lib.mkForce false;
      gcr-ssh-agent.enable = lib.mkForce false;
    };
  };
  age = {
    identityPaths = [
      "/home/jules/.ssh/jules_estradiol_agenix"
      "/home/jules/.ssh/id_ed25519"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets.ssh-signing-key = {
      file = lib.path.append src "secrets/id_ed25519.age";
      path = "/home/jules/.ssh/id_ed25519";
      mode = "600";
      owner = "jules";
      group = "users";
    };
  };

  programs.ssh = {
    startAgent = true;
    askPassword = getBinary pkgs.wayprompt;
    enableAskPassword = config.local.wayland.enable;
    agentTimeout = "2h";
  };

  environment.systemPackages = with pkgs; [wayprompt];

  local.home = {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = false;
    };
    programs = {
      wayprompt = enabled' {
        settings = {
          general = {
            font-regular = "${config.stylix.fonts.monospace.name}:size=14";
          };
        };
      };
      ssh = enabled' {
        addKeysToAgent = "yes";
        matchBlocks."*" = {
          identityFile = [
            "~/.ssh/id_ed25519"
            "~/.ssh/id_second"
            "~/.ssh/jules_estradiol_agenix"
          ];
        };
      };
    };
  };
}
