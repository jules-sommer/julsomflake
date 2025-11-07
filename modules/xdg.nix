{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled' flatten genAttrs foldl' recursiveUpdate;
in {
  local.home.xdg = {
    terminal-exec = enabled' {
      settings = {
        default = ["kitty.desktop"];
      };
    };
    mimeApps = enabled' {
      associations = {
        added = {
          "inode/directory" = ["joshuto.desktop" "dolphin.desktop"];
        };
      };
      defaultApplicationPackages = flatten [
        (with pkgs; [
          imv
          mpv
          neovim
          zen-browser
        ])

        (with pkgs.kdePackages; [
          dolphin
          okular
        ])
      ];
      defaultApplications = foldl' recursiveUpdate {} [
        # NOTE: image formats with imv
        (genAttrs [
          "image/png"
          "image/jpeg"
          "image/jpg"
          "image/gif"
          "image/webp"
          "image/svg+xml"
          "image/bmp"
        ] (_: "imv.desktop"))

        # NOTE: video files with mpv
        (genAttrs [
          "video/mp4"
          "video/x-matroska"
          "video/webm"
          "video/mpeg"
          "video/quicktime"
        ] (_: "mpv.desktop"))

        # NOTE: text with neovim
        (genAttrs [
          "text/plain"
          "text/markdown"
          "application/json"
          "application/x-yaml"
          "text/x-yaml"
        ] (_: "nvim.desktop"))

        # NOTE: use kde's ark for archives
        (genAttrs [
          "application/zip"
          "application/x-tar"
          "application/x-compressed-tar"
          "application/gzip"
          "application/x-gzip"
          "application/x-bzip"
          "application/x-bzip2"
          "application/x-7z-compressed"
          "application/x-rar"
        ] (_: "ark.desktop"))

        # NOTE: use zen-browser for links
        (genAttrs [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
          "text/html"
          "text/xml"
          "application/xhtml+xml"
        ] (_: "zen.desktop"))

        # NOTE: anddd the nice and easy single mimetype settings
        {
          "application/pdf" = "okular.desktop";
          "inode/directory" = "dolphin.desktop";
        }
      ];
    };
  };
}
