_: let
  inherit (builtins) readFile;
in {
  config.local.home.programs.fish.functions.zrun = {
    description = "A function that calls `zig build <run-step>` but removes the full command output since it can be unwieldy when linking many libraries.";
    body = readFile ./zrun.fish;
  };
}
