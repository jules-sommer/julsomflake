{...}: let
  available_cores = 12;
  max_jobs = 3;

  max_cores =
    available_cores
    / max_jobs;
in {
  # Ryzen 5 7600X
  # 12 cores on estradiol
  # 4.4 <-> 5.4 GHz clock speed

  # These settings allow nix builders to do the following:
  #   1. Build a maximum of 3 derivations at once.
  #   2. Each derivation being built gets access to 4 cores.
  #   3. This means that 3 jobs running with 4 cores use all 12 cores.
  nix.settings = {
    max-jobs = max_jobs;
    cores = max_cores;
  };

  environment.variables = {
    NIX_BUILD_CORES = max_cores;
  };
}
