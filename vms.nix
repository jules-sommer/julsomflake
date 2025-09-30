{
  self,
  lib,
  helpers,
  ...
}: let
  inherit (lib) mapAttrs;
in
  mapAttrs
  (
    hostname: {
      config,
      pkgs,
      ...
    }:
      builtins.trace (helpers.toPretty {} hostname) (
        let
          ssh = pkgs.writeScript "vm-ssh" ''
            # do not verify the host key, do not store the host key, do not show a warning about the host key
            ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
                -o User=jules localhost -p $SSH_VM_PORT "$@"
          '';

          exit = pkgs.writeScript "vm-exit" ''
            ${ssh} /run/wrappers/bin/doas /run/current-system/sw/bin/systemctl poweroff
          '';
        in
          pkgs.writeShellScript "${hostname}-vm" ''
            export SSH_VM_PORT=''${SSH_VM_PORT:-60022}

            THIS_PID=$$

            VM_TEMP_DIR=$(mktemp -d /tmp/${hostname}-XXXXXX)
            cd $VM_TEMP_DIR

            echo \n\n
            echo 'Starting VM...'
            echo \n

            QEMU_NET_OPTS="hostfwd=tcp::$SSH_VM_PORT-:22" ${config.virtualisation.vmVariant.system.build.vm}/bin/run-nixos-vm &
            QEMU_PID=$!

            monitor() {
              tail --pid=$QEMU_PID -f /dev/null
              kill $THIS_PID
            }
            cleanup() {
              echo
              echo
              echo "The VM has exited. You can now have your normal shell back."
              echo
              rm -rf $VM_TEMP_DIR
              exit
            }
            trap cleanup EXIT

            monitor &
            MONITOR_PID=$!

            export ssh="${ssh}"
            export exit="${exit}"

            sleep 1

            while kill -0 $MONITOR_PID 2>/dev/null; do
              echo "Use $(tput setaf 2)\$ssh$(tput sgr0) to execute commands in the VM"
              echo "Use $(tput setaf 1)\$exit$(tput sgr0) to power off the VM"
              echo "Press $(tput setaf 4)Ctrl+D$(tput sgr0) to see this message again"
              $SHELL
            done
          ''
      )
  )
  self.nixosConfigurations
