{
  lib,
  helpers,
  ...
}: x: builtins.trace (helpers.toPretty {} x) x
