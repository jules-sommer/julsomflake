_: let
  inherit (builtins) readFile;
in {
  config.local.home.programs.fish.functions.pretty-uptime = {
    description = "Pretty prints the systems current uptime.";
    body = readFile ./uptime.fish;
  };
}
