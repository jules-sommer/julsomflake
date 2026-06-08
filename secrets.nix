let
  estradiol = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKa+NotW65h3HVyXzHAjrwxixpRUPi2uUmCQLMlr/98O root@jules-pc"; # /etc/ssh/ssh_host_ed25519_key.pub
  jules = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwxJcAWuHkKy/Ar37aIoqg34CDcZu7/bh978nYkOgzj jules@estradiol"; # ~/.ssh/id_ed25519.pub

  users = [jules];
  systems = [estradiol];

  all = users ++ systems;
in {
  "secrets/wifi-rcmp-surveillance.age".publicKeys = all;

  # backups
  "secrets/restic-password.age".publicKeys = all;
  "secrets/restic-repo-path.age".publicKeys = all;
  "secrets/restic-htpasswd.age".publicKeys = all;
  "secrets/restic-rclone-s3-env.age".publicKeys = all;

  # http
  "secrets/cloudflare-api-token.age".publicKeys = all;

  # pihole
  "secrets/pihole-password.age".publicKeys = all;
  "secrets/pihole-totp-secret.age".publicKeys = all;

  # vaultwarden
  "secrets/vaultwarden-env.age".publicKeys = all;

  # forgejo git instance
  "secrets/forgejo-secrets.age".publicKeys = all;
  "secrets/forgejo-runner-token.age".publicKeys = all;

  "secrets/paperless-admin-password.age".publicKeys = all;

  # filebrowser-quantum
  "secrets/filebrowser-quantum.env.age".publicKeys = all;

  "secrets/id_ed25519.age".publicKeys = systems;
}
