_: let
  inherit (builtins) readFile;
in {
  config.local.home.programs.fish.functions.mkdirs = {
    description = ''
      Combines functions of touch and mkdir to create directory structure
      recursively and finally the file itself (with sudo if needed).
    '';
    body = readFile ./mkdirs.fish;
  };
}
