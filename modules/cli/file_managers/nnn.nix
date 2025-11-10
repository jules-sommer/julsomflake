{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf cmd enabled';
  hasNnn = config.local.cli.nnn.enable;
in {
  local.shells.aliases = {
    lsn = "nnn";
  };
  local.home = mkIf hasNnn {
    programs.nnn = enabled' {
      package = pkgs.nnn.override {withNerdIcons = true;};
      bookmarks = {
        d = "~/000_dev";
        z = "~/000_dev/010_zig";
        n = "~/000_dev/000_nix";
        D = "~/080_downloads";
        m = "~/060_media";
        s = "~/060_media/005_screenshots";
      };

      extraPackages = with pkgs; [
        ffmpegthumbnailer
        mediainfo
        sxiv
        zoxide # for autojump
        imagemagick # for imgresize
        rsync # for rsynccp
        file # for preview-tui
        jq # useful for various plugins
      ];

      plugins = {
        src = "${pkgs.nnn}/share/plugins";
        mappings = {
          j = "autojump";
          b = "bulknew";
          p = "preview-tui";
          o = "organize";
          d = "dups";
          f = "fixname";
          i = "imgresize";
          l = "launch";
          k = "pskill";
          r = "rsynccp";
          n = "renamer";
        };
      };
    };

    home.sessionVariables = {
      NNN_TERMINAL = "kitty";
      NNN_FIFO = "/tmp/nnn.fifo";
      NNN_PLUG = "j:autojump;b:bulknew;p:preview-tui;o:organize;d:dups;f:fixname;i:imgresize;l:launch;k:pskill;r:rsynccp;n:renamer";
    };

    xdg.desktopEntries.nnn = {
      name = "nnn";
      genericName = "File Manager";
      comment = "TUI file manager";
      exec = cmd ["kitty" "nnn" "%U"];
      icon = "utilities-terminal";
      terminal = true;
      type = "Application";
      categories = ["System" "FileTools" "FileManager"];
      mimeType = ["inode/directory"];
    };
  };
}
