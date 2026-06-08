{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled' enabled;
in {
  environment = {
    systemPackages = [pkgs.git];
    etc.gitconfig.text = ''
      [safe]
          directory = /home/jules/000_dev/000_nix/julsomflake
          directory = /home/jules/000_dev/000_nix/newsomvim
          directory = /home/jules/000_dev/000_nix/packages
          directory = /home/jules/000_dev/000_nix/nvf-source
    '';
  };
  local = {
    home.programs = {
      gh = enabled' {
        extensions = with pkgs; [gh-eco];
        hosts = {
          "github.com" = {
            user = "jules-sommer";
          };
          "git.nixfox.ca" = {
            user = "Jules";
          };
          "git.estradiol.ca" = {
            user = "jules";
          };
        };
        gitCredentialHelper = enabled' {
          hosts = [
            "https://github.com"
            "https://gist.github.com"
            "https://git.nixfox.ca"
            "https://git.estradiol.ca"
          ];
        };
      };

      delta = enabled' {
        enableGitIntegration = true;
      };

      git = enabled' {
        settings.user = {
          name = "jules-sommer";
          email = "jsomme@pm.me";
        };

        ignores = [
          "*~"
          "~*"
          "zig-out/**/*"
          ".zig-cache/**/*"
          "target/**/*"
        ];

        signing = {
          key = "/home/jules/.ssh/id_ed25519.pub";
          signByDefault = true;
          format = "ssh";
        };

        settings.gpg.format = "ssh";

        includes = [
          {
            condition = "hasconfig:remote.*.url:*github.com*/**";
            contents = {
              user = {
                name = "Jules";
                email = "jsomme@pm.me";
              };
              commit.gpgsign = true;
              gpg.format = "ssh";
              user.signingkey = "/home/jules/.ssh/id_ed25519.pub";
            };
          }
          {
            condition = "hasconfig:remote.*.url:*git.nixfox.ca*/**";
            contents = {
              user = {
                name = "Jules";
                email = "jsomme@pm.me";
              };
              commit.gpgsign = true;
              gpg.format = "ssh";
              user.signingkey = "/home/jules/.ssh/id_ed25519.pub";
            };
          }
        ];
      };
    };

    shells.aliases = {
      clone = "gix clone";
      gco = "git checkout";
      gc = "git commit";
      gca = "git commit -a";
      grsh = "git remote show";
      grset = "git remote set-url";
      gra = "git remote add";
    };
  };

  programs.git = {
    lfs = enabled' {
      enablePureSSHTransfer = true;
    };

    config = {
      init = {
        defaultBranch = "main";
      };
      url = {
        "https://github.com/" = {
          insteadOf = [
            "gh:"
            "github:"
          ];
        };
      };
    };
  };
}
