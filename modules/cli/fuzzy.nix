{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled' enableShellIntegrations mkMerge;
in {
  environment.systemPackages = with pkgs; [zoxide];
  local.home.programs = {
    ripgrep = enabled' {
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--hidden"
        "--glob=!.git/*"
        "--glob=!.cache/*"
        "--glob=!.zig-cache/*"
        "--colors=line:none"
        "--colors=line:style:bold"
        "--smart-case"
        "--type-add=archive:*.{zip,rar,7z,gz,bz2,xz,tar,tgz,tbz,tbz2,txz,tar.gz,tar.bz2,tar.xz,tar.zst,zst,lz,lzma,lzo,Z,cab,arj,ace,zoo,cpio,rpm,deb,dmg,iso,jar,war,ear,apk,aar}"
        "--type-add=tar:*.{tar,tgz,tbz,tbz2,txz,tar.gz,tar.bz2,tar.xz,tar.zst}"
        "--type-add=image:*.{jpg,jpeg,png,gif,bmp,tiff,tif,webp,svg,ico,psd,xcf,heic,heif,avif,jxl,raw,cr2,nef,arw,dng}"
        "--type-add=video:*.{mp4,mkv,avi,mov,wmv,flv,webm,m4v,mpg,mpeg,m2v,3gp,3g2,mts,m2ts,ts,vob,ogv,f4v,rm,rmvb,asf,amv,divx}"
      ];
    };
    fzf = enabled' (mkMerge [
      {
        defaultOptions = [
          "--height 40%"
          "--border"
        ];
      }
      (enableShellIntegrations ["fish" "zsh" "bash"] true)
    ]);
  };
}
