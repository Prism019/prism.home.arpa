{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      libarchive
      zip unzip # .zip
      gzip # .gz
      xz # .xz
      p7zip # .7z
      unrar # .rar
    ];
  };
}