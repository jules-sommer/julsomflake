{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit
    (lib)
    mkEnableOpt
    enabled
    mkIf
    enabled'
    enableShellIntegrations
    foldl'
    recursiveUpdate
    ;
  cfg = config.local.development;
in {
  options.local.development =
    mkEnableOpt "Enable development tools and utilities.";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      neovim
      vimv-rs
    ];

    local = {
      shells.aliases = {
        v = "nvim";
        vv = "vimv";
        vtest = "nix run /home/jules/000_dev/000_nix/newsomvim";
      };

      home.xdg.desktopEntries.nvim = {
        name = "Neovim";
        genericName = "Text Editor";
        comment = "Edit text files";
        exec = "nvim %F";
        icon = "nvim";
        terminal = true;
        type = "Application";
        categories = ["Utility" "TextEditor"];
        mimeType = [
          "text/plain"
          "text/markdown"
          "application/json"
          "application/x-yaml"
          "text/x-yaml"
          "text/english"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
          "text/x-rust"
          "text/x-python"
          "text/x-python3"
          "application/x-python"
          "text/x-zig"
          "application/x-zig"
          "text/x-nix"
          "application/x-nix"
          "text/x-fish"
          "application/toml"
          "text/x-toml"
          "application/xml"
          "text/xml"
          "text/x-lua"
          "application/x-lua"
          "text/css"
          "text/javascript"
          "application/javascript"
          "text/x-typescript"
          "application/typescript"
        ];
      };
    };
  };
}
