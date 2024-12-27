set fallback
hostname := env_var_or_default("hostname", "estradiol")

repl:
  nix repl --expr 'builtins.getFlake "/home/jules/000_dev/000_nix/nix_config_rewrite"'

build:
  valid_actions=("switch" "boot" "test" "build" "dry-build" "dry-activate" "edit" "repl" "build-vm" "build-vm-with-bootloader" "build-image" "list-generations")
  echo {{hostname}}  

build-new action='switch' host=hostname:
    #!/usr/bin/env fish 
    set action {{action}}
    set host {{host}}
    set valid_actions {"switch","boot","test","build","dry-build","dry-activate","edit","repl","build-vm","build-vm-with-bootloader","build-image","list-generations"}

    if contains $action $valid_actions
      echo "Running `$action` on .#$host"
    end
  
    doas nixos-rebuild $action --flake .#$host --show-trace
    
