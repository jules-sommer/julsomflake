set fallback
hostname := env_var_or_default("hostname", "estradiol")

check:
  nix flake check --show-trace --extra-experimental-features pipe-operators 

repl:
  nix repl --show-trace --extra-experimental-features pipe-operators --file ./repl.nix

build action='switch' host=hostname:
    #!/usr/bin/env fish 
    set action {{action}}
    set host {{host}}
    set valid_actions {"switch","boot","test","build","dry-build","dry-activate","edit","repl","build-vm","build-vm-with-bootloader","build-image","list-generations"}
    set valid_hosts {"estradiol", "progesterone"}

    if contains $action $valid_actions and contains $host $valid_hosts
      echo "Running `$action` on .#$host"
      doas nixos-rebuild $action --flake .#$host --show-trace
    end
