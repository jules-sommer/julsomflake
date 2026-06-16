/**
Build a shell command that POSTs `body` to the ntfy backups topic.
`tags` sets the ntfy emoji shortcode, `priority` its urgency.
Returns a string suitable for a systemd service `script`.
*/
{
  pkgs,
  lib,
}: let
  inherit (lib) getExe;
  curl = getExe pkgs.curl;
in
  {
    tags ? "white_check_mark",
    priority ? "default",
    topic ? "backups",
    server ? "https://ntfy.julsom.link",
  }: body: ''
    ${curl} -H "Authorization: Bearer $NTFY_TOKEN" \
      -H "Priority: ${priority}" \
      -H "Tags: ${tags}" \
      -d "${body}" \
      ${server}/${topic}
  ''
