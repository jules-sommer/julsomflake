id="${1:-}"
log=/tmp/mako-focus-debug.log

debug() {
    [[ -f "$log" ]] || return 0
    echo "[$(date +%T)] $*" >> "$log"
}

: "${NIRI_SOCKET:=${XDG_RUNTIME_DIR:-}/niri/socket}"
export NIRI_SOCKET

debug "socket: '$NIRI_SOCKET' exists=$(test -S "$NIRI_SOCKET" && echo yes || echo no)"

if [[ -f "$log" ]]; then
    echo "[$(date +%T)] niri windows:" >> "$log"
    jq -r '.[] | "  id=\(.id) app_id=\(.app_id) title=\(.title)"' <<< "$windows" >> "$log"
fi

if [[ -z "$id" ]]; then
    debug "error: no notification id provided"
    exit 1
fi

debug "--- id=$id ---"

notif=$(makoctl list | jq -c ".data[][] | select(.id.data == ($id | tonumber))" 2>/dev/null | head -n1)
debug "notif: $notif"

makoctl dismiss -n "$id"

if [[ -z "$notif" ]]; then
    debug "notification not found in makoctl list"
    exit 0
fi

app_name=$(jq -r '."app-name".data // ""' <<< "$notif")
desktop_entry=$(jq -r '."desktop-entry".data // ""' <<< "$notif")
debug "app_name='$app_name' desktop_entry='$desktop_entry'"

if [[ -z "$app_name" && -z "$desktop_entry" ]]; then
    debug "no identity to match on"
    exit 0
fi

windows=$(niri msg -j windows)

if [[ -n "${MAKO_FOCUS_DEBUG:-}" ]]; then
    echo "[$(date +%T)] niri windows:" >> "$log"
    jq -r '.[] | "  id=\(.id) app_id=\(.app_id) title=\(.title)"' <<< "$windows" >> "$log"
fi

window_id=$(jq -r \
    --arg name "$app_name" \
    --arg de "$desktop_entry" '
    def segs(s): s | ascii_downcase | split(".");
    def words(s): s | ascii_downcase | split(" ") | map(select(length > 2));
    .[] | select(
        (.app_id | ascii_downcase) as $aid |
        ($de != "" and $aid == ($de | ascii_downcase)) or
        ($name != "" and (words($name) | any(. as $w | segs($aid) | any(. == $w)))) or
        ($name != "" and ($aid | contains($name | ascii_downcase))) or
        ($name != "" and (.title | ascii_downcase | contains($name | ascii_downcase)))
    ) | .id
' <<< "$windows" | head -n1)

debug "matched window_id='$window_id'"

if [[ -z "$window_id" ]]; then
    debug "no matching window found"
    exit 0
fi

niri msg action focus-window-by-id --id "$window_id"
debug "focused window $window_id"
