argparse b/bat -- $argv
or return

set -l run_step $argv[1]
if test -z "$run_step"
    set run_step run
end
set -l rest_args $argv[2..]

set -l color_flag on
if set -q _flag_bat
    set color_flag off
end

set -l cmd "zig build $run_step --color $color_flag $rest_args 2>&1 \
                    | sed -u '/^\/nix\/store.*zig build-exe/d' \
                    | sed -u '/^error: the following command failed/q' \
                    | sed -u 's/^error: the following command failed with \([0-9]*\) compilation errors:\$/error: failed with \1 compilation errors/'"

if set -q _flag_bat
    set cmd "$cmd | bat -f -lzig"
end

eval $cmd
