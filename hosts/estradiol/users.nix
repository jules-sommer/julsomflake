{pkgs, ...}: {
  users.users.bun = {
    isNormalUser = true;
    initialPassword = "bun";
    useDefaultShell = false;
    createHome = true;
    shell = pkgs.zsh;

    extraGroups = [
      "users"
      "rtkit"
      "networkmanager"
    ];
  };
}
