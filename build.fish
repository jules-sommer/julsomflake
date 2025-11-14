#!/usr/bin/env cached-nix-shell
#!nix-shell -p fish -i fish libnotify

argparse 'a/action=' 's/specialisation=' 'h/host=' 'c/cache=' v/verbose d/dry i/interactive b/background -- $argv
or return 1

set flake_dir (test -n "$NIXOS_FLAKE_DIR"; and echo $NIXOS_FLAKE_DIR; or echo ".")
cd $flake_dir
or begin
    echo "Error: Cannot access flake directory '$flake_dir'" >&2
    return 1
end

set action (test -n "$_flag_action"; and echo $_flag_action; or echo "switch")
set host (test -n "$_flag_host"; and echo $_flag_host; or hostname)
set specialisation $_flag_specialisation
set cache $_flag_cache

set valid_actions switch boot test build dry-build dry-activate edit repl build-vm build-vm-with-bootloader build-image list-generations
set valid_hosts estradiol progesterone

if set -q _flag_dry
    set action dry-activate
end

if not contains $action $valid_actions
    echo "Error: Invalid action '$action'" >&2
    return 1
end

if not contains $host $valid_hosts
    echo "Error: Invalid host '$host'" >&2
    return 1
end

if set -q _flag_background; and set -q _flag_interactive
    echo "Error: --background and --interactive are mutually exclusive" >&2
    return 1
end

if test -n "$specialisation"
    set available_specs (nix eval --json ".#nixosConfigurations.estradiol.config.specialisation" --apply 'builtins.attrNames' 2>/dev/null | jq -r '.[]')
    if not contains $specialisation $available_specs
        echo "Error: Invalid specialisation '$specialisation' for host '$host'" >&2
        echo "Available specialisations: $available_specs" >&2
        return 1
    end
end

set cmd doas nixos-rebuild $action --flake ".#$host"

if test -n "$specialisation"
    set -a cmd --specialisation $specialisation
end

if test -n "$cache"
    for substituter in (string split ',' $cache)
        set -a cmd --option extra-substituters $substituter
    end
end

if set -q _flag_verbose
    set -a cmd --show-trace
end

set -a cmd $argv

printf "Running "
set_color brcyan -o
printf "`%s` " $action
set_color normal
printf "on "
set_color brcyan -o
printf ".#%s" $host

if test -n "$specialisation"
    printf " (with specialisation "
    set_color brcyan -o
    printf "`%s`" $specialisation
    set_color normal
    printf ")\n"
else
    printf "\n"
end

set_color brcyan -o
printf "`%s`\n\n" (string join ' ' -- $cmd)
set_color normal

if set -q _flag_background
    doas true
    or begin
        echo "Error: Authentication failed" >&2
        return 1
    end

    set log_file /tmp/nixos-rebuild-(date +%Y%m%d-%H%M%S).log
    fish -c "
        cd $flake_dir
        if $cmd &>$log_file
            notify-send 'NixOS Rebuild' '$action on $host completed' -u normal
        else
            notify-send 'NixOS Rebuild' '$action on $host failed — see $log_file' -u critical
        end
    " &>/dev/null &
    disown $last_pid
    printf "Rebuild running in background. Log: %s\n" $log_file
    return 0
end

if set -q _flag_interactive
    if confirm --prompt "Please confirm y/n to run this command"
        $cmd
    else
        set_color brmagenta -o
        echo "Aborting..."
        set_color normal
    end
else
    $cmd
end
