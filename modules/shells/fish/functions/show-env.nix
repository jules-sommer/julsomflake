{pkgs, ...}: {
  config.local.home.programs.fish.functions.show-env = {
    description = "Pretty-print environment with bat";
    body = ''
      printenv -0 \
        | string split0 \
        | string replace -r '^(.*?)=(.*)$' '$1 = $2' \
        | sort \
        | ${pkgs.bat}/bin/bat -l ini
    '';
  };
}
