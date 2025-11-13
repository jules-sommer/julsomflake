_: let
  inherit (builtins) readFile;
in {
  config.local.home.programs.fish.functions.load-env-file = {
    description = ''
      Takes a path argument for a file (.env or .ini or other textual
      key-value pair file) and loads each item as a global, exported fish
      shell variable.
    '';
    body = readFile ./load-env-file.fish;
  };
}
