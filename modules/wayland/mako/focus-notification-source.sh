#!/usr/bin/env cached-nix-shell
#!nix-shell -i bash -p mako libnotify jq

id="$1"

{
  echo "=== Notification ID: $id ==="
  
  # Dump the FULL makoctl list output
  echo "Full makoctl list JSON:"
  makoctl list | jq '.'
  
  echo ""
  echo "=== Finding notification with id=$id ==="
  notif_json=$(makoctl list | jq ".data[] | select(.id.data == $id)")
  echo "Matched notification:"
  echo "$notif_json" | jq '.'
  
  echo ""
  echo "=== Trying to extract app-name ==="
  app_name=$(echo "$notif_json" | jq -r '."app-name".data')
  echo "App name extracted: '$app_name'"
  
} >> /tmp/mako-debug.log 2>&1

makoctl dismiss -n "$id"
