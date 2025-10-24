#!/usr/bin/env fish

set valid_actions {"switch", "test", "boot"}
echo len $argv

sudo nixos-rebuild switch
