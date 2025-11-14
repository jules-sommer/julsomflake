{
  config,
  packages,
  lib,
  ...
}: let
  cfg = config.local.cli.starship;
  inherit (packages) themes_rose-pine_starship;
  inherit (lib) concatStrings mkIf foldl' recursiveUpdate mkEnableOpt enabled';
in {
  options.local.cli.starship = mkEnableOpt "Enable starship shell prompt.";

  config.local.home.programs.starship = mkIf cfg.enable (enabled' {
    enableFishIntegration = true;
    enableTransience = true;
    settings =
      # theme = builtins.fromTOML (builtins.readFile "${themes_rose-pine_starship}/rose-pine.toml");
      foldl' recursiveUpdate {} [
        # theme
        {
          format = concatStrings [
            "[╭─](#ff2199)"
            " "
            "($jobs )"
            "($status )"
            "$directory"
            "$all"
            "($cmd_duration)"
            "$line_break"
            "[╰─](#ff2199)"
            "$username"
            "$hostname"
            " "
            "$character"
          ];
          right_format = "$time$shell$sudo";
          character = {
            success_symbol = "||>";
            error_symbol = "~~>";
          };

          time = {
            disabled = false;
            format = "[󱑈 $time]($style)";
            # time_format = "%H:%M";
            # time_format = "%r";
            style = "bold fg:time";
            use_12hr = true;
          };

          sudo = {
            format = "[$symbol]($style)";
            symbol = " ";
            disabled = false;
          };

          jobs = {
            symbol = "󰫣 ";
            disabled = false;
          };

          status = {
            disabled = false;
            format = "[$symbol]($style) ";
            symbol = " ";
            not_executable_symbol = " ";
            not_found_symbol = " ";
            sigint_symbol = " ";
            signal_symbol = " ";
          };

          cmd_duration = {
            disabled = false;
            format = "took [ $duration]($style) ";
            style = "bold fg:duration";
            min_time = 500;
          };

          git_branch = {
            format = "[$symbol$branch]($style) ";
            style = "bold fg:git";
            symbol = " ";
          };

          nix_shell = {
            symbol = " ";
            format = "via [$symbol$state]($style) ";
            pure_msg = "";
            impure_msg = "";
            heuristic = true;
          };

          git_status = {
            format = "[ $all_status$ahead_behind ]($style)";
            style = "fg:text_color bg:git";
            disabled = true;
          };
        }
      ];
  });
}
