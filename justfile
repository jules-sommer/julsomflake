set fallback
hostname := env_var_or_default("hostname", "estradiol")

check:
  nix flake check --show-trace --extra-experimental-features pipe-operators 

repl:
  nix repl --show-trace --extra-experimental-features pipe-operators --file ./repl.nix

build action='switch' host=hostname specialisation="none":
    #!/usr/bin/env fish 
    set action {{action}}
    set specialisation {{specialisation}}
    set host {{host}}
    set valid_actions {"switch","boot","test","build","dry-build","dry-activate","edit","repl","build-vm","build-vm-with-bootloader","build-image","list-generations"}
    set valid_hosts {"estradiol", "progesterone"}

    if contains $action $valid_actions and contains $host $valid_hosts
      if test $specialisation = "none"
        echo "Running `$action` on .#$host"
        doas nixos-rebuild $action --flake .#$host --show-trace
      else
        echo "Running `$action` on .#$host (with specialisation `$specialisation`)"
        doas nixos-rebuild $action --flake .#$host -c $specialisation --show-trace
      end
    end

specialisation which:
  #!/usr/bin/env fish 
  set specialisation {{which}}
