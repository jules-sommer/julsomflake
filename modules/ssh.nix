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
      # "/home/jules/.ssh/jules_estradiol_agenix"
      # "/home/jules/.ssh/id_ed25519"

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

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  local.home = {
    systemd.user.sessionVariables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = false;
    };
    programs = {
      git.extraConfig = {
        gpg.format = "ssh";
        user.signingKey = "~/.ssh/id_ed25519.pub";
        commit.gpgsign = true;
      };

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
