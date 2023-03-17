{ config, pkgs, lib, ... }:

{
    home = {
      xdg.configFile."Code/User/settings.json".source =
         config.lib.file.mkOutOfStoreSymlink
         "${config.home.homeDirectory}/dev/dotfiles/nix/config/settings.json";
      
  };
}