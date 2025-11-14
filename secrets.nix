let
  estradiol = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKa+NotW65h3HVyXzHAjrwxixpRUPi2uUmCQLMlr/98O root@jules-pc";
  jules = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIG9S2gipqDLPux18Hy/2SjLPhranC5DxI28xV50xwtc jules@estradiol";

  users = [jules];
  systems = [estradiol];

  all = users ++ systems;
in {
  "./secrets/wifi-rcmp-surveillance.age".publicKeys = all;
}
