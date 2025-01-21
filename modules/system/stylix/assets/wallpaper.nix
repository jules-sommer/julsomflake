{ pkgs, lib, ... }:

let
  inherit (builtins)
    any
    toString
    readDir
    ;
  inherit (lib)
    path
    toLower
    filter
    attrNames
    hasSuffix
    ;
  hasImageExtension =
    filename:
    any (ext: hasSuffix ext (toString (toLower filename))) [
      ".png"
      ".jpg"
      ".jpeg"
      ".bmp"
      ".webp"
    ];

  getImagePaths =
    dir:
    let
      contents = readDir dir;
      imageFiles = filter (name: contents.${name} == "regular" && hasImageExtension name) (
        attrNames contents
      );
    in
    map (name: dir + "/${name}") imageFiles;

  getName =
    path:
    let
      name = builtins.baseNameOf path;
      matches = builtins.match "(.+)(\\.[^.]+)" name;
      basename = builtins.elemAt matches 0;
      extension = builtins.elemAt matches 1;
    in
    "${basename}-dim${extension}";

  createImage =
    brightness: contrast: fillColor: img:
    pkgs.runCommand (getName img) { } ''
      ${pkgs.imagemagick}/bin/convert "${img}" \
        -brightness-contrast ${toString brightness},${toString contrast} \
        -fill "${fillColor}" \
        $out
    '';

  inputImgs = getImagePaths ./.;

  brightness = -20;
  contrast = 30;
  fillColor = "black";
in
map (path: createImage brightness contrast fillColor path) inputImgs
