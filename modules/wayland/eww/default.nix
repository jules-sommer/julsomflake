{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enableShellIntegrations enabled' getBinary;

  eww-niri-workspaces = getBinary pkgs.julespkgs.eww-niri-workspaces;
  jq = getBinary pkgs.jq;
  bash = getBinary pkgs.bash;

  configDir = pkgs.runCommand "eww-config" {} ''
    mkdir -p $out/scripts
    cp -r ${./eww-config}/* $out/

    # Write wrapper script directly
    cat > $out/scripts/eww-niri-workspaces << 'EOF'
      #!${bash}
      ${eww-niri-workspaces} | ${jq} -c '
      .outputs |= (
        . | to_entries | map(
          .value.workspaces |= sort_by(.index)
        ) | from_entries
      )
    '
    EOF
    chmod +x $out/scripts/eww-niri-workspaces
  '';
in {
  environment.systemPackages = with pkgs; [julespkgs.eww-niri-workspaces];
  local.home.home.packages = with pkgs; [julespkgs.eww-niri-workspaces];

  local.home.programs.eww =
    enabled' (enableShellIntegrations ["bash" "fish" "zsh"] true)
    // {
      inherit configDir;
    };
}
