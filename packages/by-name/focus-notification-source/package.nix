{
  writeShellApplication,
  pkgs,
}:
writeShellApplication {
  name = "focus-notification-source";
  runtimeInputs = with pkgs; [mako jq niri-unstable];
  text = builtins.readFile ./script.sh;
}
