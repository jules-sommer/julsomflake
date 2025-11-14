{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled' enabled;
in {
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
        };
        gitCredentialHelper = enabled' {
          hosts = [
            "https://github.com"
            "https://gist.github.com"
            "https://git.nixfox.ca"
          ];
        };
      };
      git = enabled' {
        settings.user = {
          name = "jules-sommer";
          email = "jsomme@pm.me";
        };

        delta = enabled;
        ignores = [
          "*~"
          "~*"
          "zig-out/**/*"
          ".zig-cache/**/*"
          "target/**/*"
        ];

        signing = {
          key = "~/.ssh/id_ed25519";
          signByDefault = true;
        };
        extraConfig.gpg.format = "ssh";

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
              user.signingkey = "~/.ssh/id_ed25519";
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
              user.signingkey = "~/.ssh/id_ed25519";
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
