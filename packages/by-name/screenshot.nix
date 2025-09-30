{
  pkgs,
  writeShellApplication,
}:
writeShellApplication {
  name = "screenshot";
  runtimeInputs = with pkgs; [
    grim
    slurp
    wl-clipboard
    coreutils
    libnotify
    xdg-user-dirs
  ];
  text = ''
    set -euo pipefail

    dir="''${SCREENSHOT_DIR:-}"

    while [ $# -gt 0 ]; do
      case "$1" in
        --dir)
          shift
          dir="''${1:-}"
          shift || true
          ;;
        *)
          echo "usage: screenshot [--dir DIR]" >&2
          exit 2
          ;;
      esac
    done

    if [ -z "$dir" ]; then
      if command -v xdg-user-dir >/dev/null 2>&1; then
        dir="$(xdg-user-dir PICTURES)/Screenshots"
      else
        dir="$HOME/Pictures/Screenshots"
      fi
    fi

    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

    grim -g "$(slurp -d)" - | tee "$file" | wl-copy -t image/png
    notify-send "Saved screenshot to $file"
  '';
}
