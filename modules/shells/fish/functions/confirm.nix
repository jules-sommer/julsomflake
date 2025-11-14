_: let
  inherit (builtins) readFile;
in {
  config.local.home.programs.fish.functions.confirm = {
    description = ''
      Asks the user to confirm yes/no, with an optional --default
      return value, and a custom --prompt to print to the user before
      reading input.
    '';
    body = readFile ./confirm.fish;
  };
}
