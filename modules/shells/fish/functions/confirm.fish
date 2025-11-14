argparse 'p/prompt=' d/default-yes -- $argv
or return 1

if set -q _flag_default_yes
    set prompt (set -q _flag_prompt && echo $_flag_prompt || echo "Continue?")
    set prompt "$prompt [Y/n] "
    set default_return 0
else
    set prompt (set -q _flag_prompt && echo $_flag_prompt || echo "Continue?")
    set prompt "$prompt [y/N] "
    set default_return 1
end

read -n 1 -l -P "$prompt" response
echo ""

switch $response
    case Y y
        return 0
    case N n
        return 1
    case ''
        return $default_return
end
