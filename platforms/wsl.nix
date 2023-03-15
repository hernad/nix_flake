{ pkgs, lib, ... }:

{
  config = {
    wsl.enable = true;
    wsl.defaultUser = "hernad";
    i18n.supportedLocales = [ "all" ];
    i18n.defaultLocale = "bs_BA.UTF-8";
  };
}
