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
    satty
  ];
  text = ''
    set -euo pipefail

    dir="''${SCREENSHOT_DIR:-}"
    edit=0

    while [ $# -gt 0 ]; do
      case "$1" in
        --dir)
          shift
          dir="''${1:-}"
          shift || true
          ;;
        --edit)
          edit=1
          shift
          ;;
        *)
          echo "usage: screenshot [--dir DIR] [--edit]" >&2
          exit 2
          ;;
      esac
    done

    if [ -z "$dir" ]; then
      if command -v xdg-user-dir >/dev/null 2>&1; then
        dir="$(xdg-user-dir PICTURES)/005_screenshots"
      else
        dir="$HOME/060_media/005_screenshots"
      fi
    fi

    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

    if [ "$edit" -eq 1 ]; then
      grim -g "$(slurp -d)" - \
        | satty \
            --filename - \
            --output-filename "$file" \
            --copy-command "wl-copy -t image/png" \
            --actions-on-enter save-to-file,save-to-clipboard \
            --early-exit
      if [ -f "$file" ]; then
        notify-send "Saved screenshot to $file"
      fi
    else
      grim -g "$(slurp -d)" - | tee "$file" | wl-copy -t image/png
      notify-send "Saved screenshot to $file"
    fi
  '';
}
