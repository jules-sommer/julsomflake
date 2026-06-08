#!/usr/bin/env cached-nix-shell
#!nix-shell -p fish -i fish libnotify systemd git

argparse 's/specialisation=' 'host=' 'c/cache=' v/verbose d/dry i/interactive b/background h/help -- $argv
or return 1

if set -q _flag_help
    printf "Usage: build [action] [flags]\n\n"
    printf "Actions (default: switch):\n"
    printf "  switch boot test build dry-build dry-activate edit repl\n"
    printf "  build-vm build-vm-with-bootloader build-image list-generations\n\n"
    printf "Flags:\n"
    printf "  -s, --specialisation <name>   Build with a specialisation\n"
    printf "      --host <name>             Target host (default: current hostname)\n"
    printf "  -c, --cache <url[,url]>       Extra substituters (comma-separated)\n"
    printf "  -v, --verbose                 Pass --show-trace to nixos-rebuild\n"
    printf "  -d, --dry                     Alias for dry-activate action\n"
    printf "  -i, --interactive             Prompt for confirmation before running\n"
    printf "  -b, --background              Run rebuild in background with notify-send\n"
    printf "      --help                    Show this help\n"
    return 0
end

set flake_dir (test -n "$NIXOS_FLAKE_DIR"; and echo $NIXOS_FLAKE_DIR; or echo ".")
cd $flake_dir
or begin
    echo "Error: Cannot access flake directory '$flake_dir'" >&2
    return 1
end

if test (count $argv) -gt 0
    set action $argv[1]
    set argv $argv[2..]
else
    set action switch
end

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
    set unit nixos-rebuild-(date +%Y%m%d-%H%M%S)

    echo "launch (nixos-rebuild): "(date +%T)

    doas systemd-run \
        --unit $unit \
        --service-type oneshot \
        --working-directory $PWD \
        --setenv PATH=/run/current-system/sw/bin:/run/wrappers/bin \
        -- $cmd[2..]
    or begin
        echo "Error: systemd-run exited with status $status" >&2
        return 1
    end

    echo "returned (nixos-rebuild): "(date +%T)

    echo "launch (notify): "(date +%T)

    systemd-run --user \
        --collect \
        --unit $unit-notify \
        --setenv UNIT=$unit \
        --setenv ACTION=$action \
        --setenv HOST=$host \
        --setenv NOTIFY=(command -v notify-send) \
        --quiet \
        -- (status fish-path) -c '
            while contains (systemctl show -p ActiveState --value $UNIT) active activating
                sleep 2
            end
            if test (systemctl show -p ActiveState --value $UNIT) = failed
                $NOTIFY -u critical "NixOS Rebuild" "$ACTION on $HOST failed — journalctl -u $UNIT"
            else
                $NOTIFY -u normal "NixOS Rebuild" "$ACTION on $HOST completed"
            end
        '

    echo "returned (notify): "(date +%T)

    printf "Rebuild launched as %s. Follow with: journalctl -u %s -f\n" $unit $unit
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
