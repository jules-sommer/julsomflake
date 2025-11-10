{lib, ...}: let
  inherit (lib) enabled';
in {
  local.shells.aliases = {
    clone = "gix clone";
    gco = "git checkout";
    gc = "git commit";
    gca = "git commit -a";
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
