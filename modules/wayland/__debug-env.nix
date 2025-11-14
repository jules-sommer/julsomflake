{writeShellScriptBin}:
writeShellScriptBin "debug-wayland-env" ''
  logfile=$(mktemp /tmp/niri-init_''${1:+$1_}XXXXXX.log)

  cat << EOF > $logfile
    SHELL: $SHELL
    USER: $USER
    WAYLAND_DISPLAY: $WAYLAND_DISPLAY
    XDG_CURRENT_DESKTOP: $XDG_CURRENT_DESKTOP
    NIRI_SOCKET: $NIRI_SOCKET
    XCURSOR_THEME: $XCURSOR_THEME
    XCURSOR_SIZE: $XCURSOR_SIZE
    WALLPAPER: $WALLPAPER
  EOF

  echo "Debug info written to: $logfile"
''
